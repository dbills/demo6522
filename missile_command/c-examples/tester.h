/* This file was automatically generated.  Do not edit! */
#undef INTERFACE
void step6502();
extern uint16_t pc;
void reset6502();
void hookexternal(void *funcptr);
void set_nmi(const uint16_t address);
int write_zp_ptr(const char *const label,const uint16_t address);
int find_label(const char *const label,uint16_t *const address);
void load_labels();
void load_image(const char *const filename);
void load_kernel();
int main(int argc,char **argv);
