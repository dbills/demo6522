#include "include.h"
#include "fake6502.h"
#include "machine.h"
#include "labels.h"

#include "vic_os.h"


static void dump_line_data() {
  uint16_t i;
  for(i = 0x2000;i < 0x2000+160;i++) {
    printf("0x%hx = 0x%hhx\n", i , ram[i]);
  }
}
// when the interrupt triggers, we go to the irq
int main(int argc, char **argv) {
  load_labels();
  print_label("dy");
  exit(0);
  assert(sizeof(ram) == 65536);
  load_kernel();
  load_image("a.p00");
  printf("irq/brk = %hx\nnmi = %hx\nreset = %hx\nuser irq($314) = %hx\n",
         get_word(0xfffe),
         get_word(0xfffa),
         get_word(0xfffc),
         get_word(0x314)
         );
  // install a hook so we can break at certain PC values
  hookexternal(hook6502);
  break_address = 0x0;
  reset6502();

  while(!break_now) {
    printf("pc = 0x%x a=%hhx\n", pc, a);
    step6502();
  }
  printf("HEEEEEEEEEEEEEELO\n");
  dump_line_data();
  return 0;
}
