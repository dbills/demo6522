/* This file was automatically generated.  Do not edit! */
#undef INTERFACE
void hookexternal(void *funcptr);
void step6502();
void exec6502(uint32_t tickcount);
void(*loopexternal)();
extern uint8_t callexternal;
void irq6502();
void nmi6502();
extern uint8_t penaltyop,penaltyaddr;
void reset6502();
uint8_t pull8();
uint16_t pull16();
void push8(uint8_t pushval);
void push16(uint16_t pushval);
void write6502(uint16_t address,uint8_t value);
uint8_t read6502(uint16_t address);
extern uint8_t opcode,oldstatus;
extern uint16_t oldpc,ea,reladdr,value,result;
extern uint32_t clockticks6502;
extern uint32_t instructions;
extern uint16_t pc;
extern uint8_t value_read;
extern uint16_t read_address;
extern int read_instruction;
extern uint8_t sp,a,x,y,status;
