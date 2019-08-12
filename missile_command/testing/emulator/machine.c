#include "include.h"
#include "fake6502.h"
#include "machine.h"
/*
  infrastructure needed for the 6502 
  emulator: fake6502.c
  and my limited 'testing' framework which allows 
  callbacks/breakpoints, etc.
*/
static char ram[RAM_SIZE];
ram_read_callback ram_read_callbacks[RAM_SIZE];
generic_ram_callback uninitialized_read_callback = NULL;
static int ram_read_count[RAM_SIZE];
static int ram_write_count[RAM_SIZE];
int break_now;           /* break as soon as possible */
uint16_t break_address;  /* address to break at */

uint8_t read6502(const uint16_t address) {
  const uint8_t data = ram_read_callbacks[address] ?
      ram_read_callbacks[address]() :
      ram[address];
  if(address <= 0xff && ram_write_count[address] == 0) {
    if(uninitialized_read_callback)
      (*uninitialized_read_callback)(pc, address);
    else {
      //fprintf(stderr, "uninitialized read 0x%hx pc = 0x%hx\n", address, pc); 
    }
  }
  ram_read_count[address]++;
  //printf("\tread 0x%hx = 0x%hhx\n", address, data);
  return data;
}

void write6502(const uint16_t address, const uint8_t value) {
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
    //irq6502();
  }
}

void interactive_step() {
  printf("press enter to single step\n");
  while(1) {
    char buf[255];
    fgets(buf,sizeof(buf), stdin);
    break_now = 0;
    step6502();
  }
}

BOOL load_image(const char *const path, const uint16_t address, const uint16_t size) {
  FILE *const fd = fopen(path, "rb");
  if(!fd) {
    fprintf(stderr,"failed to open file %s\n", path);
    perror("Error");
    return FALSE;
  }
  const int rtn = fread(&ram[57344], 1, 8192, fd);
  assert(rtn == size);
  fclose(fd);
  return TRUE;
}

BOOL load_p00(const char *const filename) {
  FILE *const fd = fopen(filename, "rb");
  if(!fd) {
    fprintf(stderr,"failed to open file %s\n", filename);
    perror("Error");
    return FALSE;
  }
  uint16_t lsb_address;
  size_t bytes_read = fread(&lsb_address, 1, sizeof(lsb_address), fd);
  assert(bytes_read == sizeof(lsb_address));
  const uint16_t address = le16toh(lsb_address);  // 6502 is LSB
  bytes_read = fread(&ram[address], 1, sizeof(ram) - address, fd);
  printf("loaded %zd bytes at 0x%x\n", bytes_read, (int)address);
  fclose(fd);
  return TRUE;
}
