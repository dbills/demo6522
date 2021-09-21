// convert sprite data exported from the inline sprite editor 'piskel'
// into a format useable by ca65 and missile command

#include <stdio.h>
 // consider piskel/*
//#include "/tmp/mc_mushrom.c"
#include "../piskel/mc_mushrom.c"

int mode = 0;
bool code = false;

#define B1(x)((unsigned char)((x) & 0xFF))
#define B2(x)((unsigned char)(((x) >> 8) & 0xFF))
#define B3(x)((unsigned char)(((x) >> 16) & 0xFF))
#define B4(x)((unsigned char)(((x) >> 24) & 0xFF))

void output_pixel(int bit) {
  if (!mode) {
    printf("\u2588");
  }
}
void write_byte(unsigned char b, int screen_col) {
  printf("  lda #$%02x\n", b);
  printf("  sta (sp_col%d),y\n", screen_col);
}

char g_name[256];
const char * make_name(const char * name, int frame, int shift) {
  sprintf(g_name, "%s%d_shift%d", name, frame, shift);
  return g_name;
}
// C is row-major order
// x[r][c]
void generate(const char * name, uint32_t * array, int frames, int rows, int columns, int skip, int shift) {
  printf(".export %s_framesL,%s_framesH", name, name);
  for (int frame = 0; frame < frames; frame++) {
    printf(", ");
    printf("%s", make_name(name, frame, shift));
  }
  printf("\n.data\n");
  printf("%s_framesL: .byte ", name);
  for (int frame = 0; frame < frames; frame++) {
    if(frame)
      printf(", ");
    printf("<(%s)", make_name(name, frame, shift));
  }
  printf("\n%s_framesH: .byte ", name);
  for (int frame = 0; frame < frames; frame++) {
    if(frame)
      printf(", ");
    printf(">(%s)", make_name(name, frame, shift));
  }
  printf("\n");
  printf(".code\n");
  for (int frame = 0; frame < frames; frame++) {
    printf(".proc %s\n", make_name(name, frame, shift));
    unsigned int dwords[rows];
    for (int row = skip; row < rows; row++) {
      printf("  ;; %2d|", row);
      unsigned int dword = 0;
      for (int col = 0; col < columns; col++) {
        int pixel_offset = row * rows + col;
        unsigned int * addr = (array +
          (frame * rows * columns) +
          pixel_offset);
        int val = * addr;
        //printf("[%d][%d] (%x) - %u\n",frame, pixel_offset,addr,val);
        dword <<= 1;
        if (val) {
          printf("\u2588");
          dword |= 1;
        } else {
          printf(" ");
        }
      }
      dword <<= 8;
      dwords[row] = dword;
      printf("| $%06x\n", dwords[row]);
    }
    for (int row = skip; row < rows; row++) {
      const unsigned int dword = dwords[row] >> shift;
      write_byte(B3(dword), 0);
      write_byte(B2(dword), 1);
      write_byte(B1(dword), 2);
      if (row < rows - 1)
        printf("  iny\n");
    }
    printf("  rts\n.endproc\n\n");
  }
}

int main(int argc, char ** argv) {
  printf(".include \"zerop.inc\"\n");
  /* int *p = (int*)x; */
  /* int r=1; */
  /* int c=2; */
  /* printf("%d,%d\n", x[r][c],*(p+(r*3)+c)); */
  generate("mushroom", (unsigned int * ) & mc_mushrom_data,
    MC_MUSHROM_FRAME_COUNT,
    MC_MUSHROM_FRAME_WIDTH,
    MC_MUSHROM_FRAME_HEIGHT,
    5, /* start row */
    0 /* shift amount */
  );

  //generate(x,2,2,2);
}
// xterm
//- Move the cursor up N lines:
//  \033[<N>A
