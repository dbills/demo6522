#include "include.h"
#include "machine.h"

static union {
  uint16_t word;
  char bytes[2];
} lsb_load_address;

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

void load_kernel() {
  // E000-FFFF   57344-65535        8K KERNAL ROM
#ifdef WSL                      /* linux on windows */
  char *path = "/mnt/c/winvice3/VIC20/kernal";
#else
  char *path = "/usr/lib/vice/VIC20/kernal";
#endif
  FILE *const fd = fopen(path, "rb");
  if(!fd) {
    fprintf(stderr,"failed to open kernel file %s\n", path);
    perror("Error");
    exit(1);
  }
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

