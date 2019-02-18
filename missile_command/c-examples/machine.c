#include "include.h"
#include "fake6502.h"
#include "machine.h"

char ram[RAM_SIZE];
ram_read_callback ram_read_callbacks[RAM_SIZE];
static int ram_read_count[RAM_SIZE];
static int ram_write_count[RAM_SIZE];
int break_now;           /* break as soon as possible */
uint16_t break_address;  /* address to break at */

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

static void interactive_step() {
  printf("press enter to single step\n");
  while(1) {
    char buf[255];
    fgets(buf,sizeof(buf),stdin);
    break_now = 0;
    step6502();
  }
}
