#include "include.h"
#include "machine.h"
#include "labels.h"
#include "fake6502.h"
/*
  support functions for pretending the machine
  in machine.c is a VIC20
*/
static union {
  uint16_t word;
  char bytes[2];
} lsb_address;

static void write_word(const uint16_t address,const uint16_t value) {
  lsb_address.word = htole16(value);
  write6502(address, lsb_address.bytes[0]);
  write6502(address + 1, lsb_address.bytes[1]);
}

void set_reset(const uint16_t address) {
  write_word(65532, address);
}

void call_label(const char *const label) {
  set_reset(get_label(label));
  reset6502();
}

void write8(const char *const label, const uint8_t value) {
    write6502(get_label(label), value);
}

void write16(const char *const label, const uint16_t address) {
    write_word(get_label(label), address);
}

void uninitialized_read(uint16_t pc,uint16_t address) {
  const char *const label = find_address(address);
  fprintf(stderr, "uninitialized read 0x%hx(label:%s) pc = 0x%hx\n", address, label ? label : "n/a", pc);
}

void load_kernel() {
  // E000-FFFF   57344-65535        8K KERNAL ROM
#ifdef WSL                      /* linux on windows */
  const char *const path = "/mnt/c/winvice3/VIC20/kernal";
#else
  const char *const path = "/usr/lib/vice/VIC20/kernal";
#endif
  load_image(path, 57344, 8192);
  // since I'm not actually booting the kernel
  // I will set up the software IRQ interrupt vector
  // myself.  This is the minimum routine, that does no
  // keyboard polling
  write6502(0x314, 0x15);
  write6502(0x315, 0xeb);
  // force jiffy clock to be anything other than 0
  // so the game's random seed generator will allow
  // the game to start
  write6502(0xa2, 0x1);

  uninitialized_read_callback = uninitialized_read;
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

