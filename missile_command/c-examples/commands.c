#include "include.h"
#include "ipc.h"

int do_set_break(const char *const args) {
  uint16_t addr;
  const int items = sscanf(args, "%hx", &addr);
  printf("args=%s items=%d break set to %x\n", args, items, addr);
  return 0;
}

int do_load_image(const char *const args) {
  return 0;
}

/* int do_read_mem(const char *const args) { */
/*   uint16_t addr, size; */
/*   char response[size * 4 + strlen("(list )")]; */
/*   memset(response, ' ', sizeof(response)); */
/*   strcpy(response, "(list "); */
/*   if(sscanf(args, "%hx %hx", &addr, &size) == 2) { */
/*     uint16_t i_mem = addr; */
/*     int i_result = 0; */
/*     for(;i < addr + size;i++) { */
/*       // the byte string + 1 for a space */
/*       i_result += sprintf(buf[i_result], "%hhd ", read6502(i)) + 1; */
/*     } */
/*     strcat */
/*     return 0; */
/*   } else */
/*     return -1; */
/* } */

void send_response(int success) {
  if(!success)
    write_response_pipe("nil");
}

#define is_command(STR, FUNC) if(!strcmp(command, STR)) success = (0 == FUNC(&message[strlen(STR)]))
void process_command(const char *const message) {
  char command[256];
  const int matched = sscanf(message, "%s", command);
  if(matched) {
    int success = 0;
    is_command("set-break", do_set_break);
    else is_command("load-image", do_load_image);
    send_response(success);
  } else {
    fprintf(stderr, "%s failed to read command\n", __func__);
  }
}

void command_loop() {
  make_command_pipes();
  while(1) {
    process_command(read_command_pipe());
  }
}
