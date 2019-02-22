/* This file was automatically generated.  Do not edit! */
#undef INTERFACE
void step6502();
extern uint16_t pc;
void load_labels();
void hookexternal(void *funcptr);
void load_kernel();
int main(int argc,char **argv);
uint8_t read6502(uint16_t address);
void call_label(const char *const label);
void write8(const char *const label,const uint8_t value);
void write16(const char *const label,const uint16_t address);
