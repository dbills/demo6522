/* This file was automatically generated.  Do not edit! */
#undef INTERFACE
char *read_command_pipe();
void make_command_pipes();
void command_loop();
void process_command(const char *const message);
void write_response_pipe(const char *const msg);
void send_response(int success);
int do_load_image(const char *const args);
int do_set_break(const char *const args);
