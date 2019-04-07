#include "include.h"
#include "fake6502.h"
#include "machine.h"
#include "labels.h"
#include "machine.h"
#include "vic_os.h"
#include "commands.h"



static void line_test() {
  uint16_t line_data = 0x2000;
  uint8_t height = 160;
  write16("lstore", line_data);
  write8("x1", 0);
  write8("y1", 0);
  write8("y2", height);
  write8("x2", 4);
  call_label("line1");

}

static void dump_line_data(const uint16_t line_data,const uint8_t height) {
  uint16_t i;
  for(i = line_data;i < line_data + height;i++) {
    printf("0x%hx = 0x%hhx\n", i , read6502(i));
  }
}


int main(int argc, char **argv) {
  load_kernel();
  load_p00("../a.p00");

  printf("irq/brk = %hx\nnmi = %hx\nreset = %hx\nuser irq($314) = %hx\n",
         get_word(0xfffe),
         get_word(0xfffa),
         get_word(0xfffc),
         get_word(0x314)
         );

  // install a hook so we can break at certain PC values
  hookexternal(hook6502);
  break_address = 0x0;

  load_labels("../labels.txt");
  line_test();
  //write16("lstore", 0x2000);
  //call_label("main");

  while(!break_now) {
    printf("pc = 0x%x a=%hhx\n", pc, a);
    step6502();
  }
  printf("HEEEEEEEEEEEEEELO\n");
  dump_line_data(0x2000,160);
  return 0;
}
