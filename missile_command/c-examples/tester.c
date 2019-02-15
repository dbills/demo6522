#include "fake6502.c"
#include <stdio.h>
#include <endian.h>
#include <assert.h>
#include <stdlib.h>

#define RAM_SIZE 65536
#define JOY0 0x9111
typedef uint8_t (*ram_read_callback)();
static char ram[RAM_SIZE];
ram_read_callback ram_read_callbacks[RAM_SIZE];
static int ram_read_count[RAM_SIZE];
static int ram_write_count[RAM_SIZE];
static int break_now;           /* break as soon as possible */
static uint16_t break_address;  /* address to break at */

union {
  uint16_t word;
  char bytes[2];
} lsb_load_address;

uint8_t read6502(uint16_t address) {
  const uint8_t data = ram_read_callbacks[address] ?
      ram_read_callbacks[address]() :
      ram[address];
  if(address <= 0xff && ram_write_count[address] == 0) {
    fprintf(stderr, "uninitialized read 0x%hx pc = 0x%hx\n", address, pc);
    //exit(1);
  }
  ram_read_count[address]++;
  //printf("\tread 0x%hx = 0x%hhx\n", address, data);
  return data;
}

void write6502(uint16_t address, uint8_t value) {
  //printf("write 0x%hx = 0x%hhx pc = %hx\n", address, value, pc);
  ram_write_count[address]++;
  ram[address] = value;
}

void load_image(const char *const filename) {
  FILE *const fd = fopen(filename, "rb");
  assert(fd);
  size_t bytes_read = fread(&lsb_load_address, 1, sizeof(lsb_load_address), fd);
  assert(bytes_read == sizeof(lsb_load_address));
  // 6502 is LSB
  uint16_t load_address = le16toh(lsb_load_address.word);
  bytes_read = fread(&ram[load_address], 1, sizeof(ram) - load_address, fd);
  printf("loaded %zd bytes at 0x%x\n", bytes_read, (int)load_address);
  // cause NMI to jump to our image location
  ram[65532] = lsb_load_address.bytes[0];
  ram[65533] = lsb_load_address.bytes[1];
  fclose(fd);
}

void hook6502() {
  //printf("hook pc = 0x%x\n", pc);
  // check if we are at a debug break point
  if(pc == break_address)
    break_now = 1;
  // fake behaviors that would happen during interrupt
  // assume 1Mhz - update jiffy clock
  if((clockticks6502 % (1000000/60)) == 0) {
    irq6502();
  }
}

uint16_t get_word(uint16_t address) {
  return le16toh(*(uint16_t *)&ram[address]);
}

void interactive_step() {
  printf("press enter to single step\n");
  while(1) {
    char buf[255];
    fgets(buf,sizeof(buf),stdin);
    break_now = 0;
    step6502();
  }
}

void load_kernel() {
  // E000-FFFF   57344-65535        8K KERNAL ROM
  FILE *const fd = fopen("/usr/lib/vice/VIC20/kernal", "rb");
  assert(fd);
  const int rtn = fread(&ram[57344], 1, 8192, fd);
  assert(rtn == 8192);
  fclose(fd);
  // since I'm not actually booting the kernel
  // I will set up the software IRQ interrupt vector
  // myself.  This is the minimum routine, that does no
  // keyboard polling
  ram[0x314] = 0x15;
  ram[0x315] = 0xeb;
  // force jiffy clock to be anything other than 0
  // so the game's random seed generator will allow
  // the game to start
  write6502(0xa2, 0x1);
}

uint8_t release_joystick_button() {
  printf("RELEASE\n");
  ram_read_callbacks[JOY0] = 0;
  return 0x20;
}

uint8_t press_joystick_button() {
  printf("PRESS\n");
  ram_read_callbacks[JOY0] = release_joystick_button;
  return 0x0f;
}

void dump_line_data() {
  uint16_t i;
  for(i = 0x2000;i < 0x2000+160;i++) {
    printf("0x%hx = 0x%hhx\n", i , ram[i]);
  }
}
// when the interrupt triggers, we go to the irq
int main(int argc, char **argv) {
  assert(sizeof(ram) == 65536);
  load_kernel();
  load_image("a.p00");
  printf("irq/brk = %hx\nnmi = %hx\nreset = %hx\nuser irq($314) = %hx\n",
         get_word(0xfffe),
         get_word(0xfffa),
         get_word(0xfffc),
         get_word(0x314)
         );
  // install a hook so we can break at certain PC values
  hookexternal(hook6502);
  break_address = 0x0;
  reset6502();

  while(!break_now) {
    printf("pc = 0x%x a=%hhx\n", pc, a);
    step6502();
  }

  dump_line_data();
  return 0;
}
