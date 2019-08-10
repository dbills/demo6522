#include <stdio.h>

int sum_n(int n) {
  return (n*(n+1))/2;
}
int partial_sum(int terms, int number) {
  return sum_n(number) - sum_n(number-terms);
}
void print_byte(int byte) {
     printf("          dc.b %d\n",byte);
}
void print_binary(int number)
{
    if (number) {
        print_binary(number >> 1);
        putc((number & 1) ? '1' : '0', stdout);
    }
}
void print_binary_byte(int byte) {
     printf("          dc.b %%");
     print_binary(byte);
     printf("\n");
 }
void print_offset_table(int j) {
    for(int terms=j;terms<8;terms++) {
      int entry = partial_sum(terms, 8);
      print_byte(entry);
    }
    print_byte(0);
}
void print_bit_table(int j) {
  printf("XBMASKS_%d ",j);
  unsigned char byte = 0;
  for(;j<8;j++) {
      byte|=0x80 >> j;
      print_binary_byte(byte);
    }
}

int main() {
  printf("XBMASKS_OFFSET_TBL\n");
  for(int j=1;j<=8;j++) {
    print_offset_table(j);
    printf("\n");
  }
  for(int j=0;j<8;j++) {
    print_bit_table(j);
  }
  return 0;
}
