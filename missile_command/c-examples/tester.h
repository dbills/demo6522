/* This file was automatically generated.  Do not edit! */
#undef INTERFACE
void step6502();
extern uint16_t pc;
void reset6502();
void hookexternal(void *funcptr);
void load_image(const char *const filename);
void load_kernel();
void print_label(const char *const label);
void load_labels();
int main(int argc,char **argv);
