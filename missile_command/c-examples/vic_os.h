/* This file was automatically generated.  Do not edit! */
#undef INTERFACE
uint8_t press_joystick_button();
uint8_t release_joystick_button();
void write6502(uint16_t address,uint8_t value);
void load_kernel();
void load_image(const char *const filename);
int find_label(const char *const label,uint16_t *const address);
int write_zp_ptr(const char *const label,const uint16_t address);
void set_nmi(const uint16_t address);
