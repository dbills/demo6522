/* This file was automatically generated.  Do not edit! */
#undef INTERFACE
uint8_t press_joystick_button();
uint8_t release_joystick_button();
void load_kernel();
const char *const find_address(const uint16_t address);
extern uint16_t pc;
void uninitialized_read(uint16_t pc,uint16_t address);
void write16(const char *const label,const uint16_t address);
void write8(const char *const label,const uint8_t value);
void reset6502();
uint16_t get_label(const char *const label);
void call_label(const char *const label);
void set_reset(const uint16_t address);
void write6502(uint16_t address,uint8_t value);
