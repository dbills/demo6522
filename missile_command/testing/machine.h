#define RAM_SIZE 65536
#define JOY0 0x9111
void step6502();
uint16_t get_word(uint16_t address);
void irq6502();
void hook6502();
void write6502(uint16_t address,uint8_t value);
uint8_t read6502(uint16_t address);
void load_image(const char *const path, const uint16_t address, const uint16_t size);
void load_p00(const char *const filename);
typedef uint8_t(*ram_read_callback)();
typedef void(*generic_ram_callback)(uint16_t pc, uint16_t address);
extern generic_ram_callback uninitialized_read_callback;
extern ram_read_callback ram_read_callbacks[RAM_SIZE];
extern int break_now;           /* break as soon as possible */
extern uint16_t break_address;  /* address to break at */
