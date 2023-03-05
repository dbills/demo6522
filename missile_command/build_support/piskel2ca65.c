// convert sprite data exported from the inline sprite editor 'piskel'
// into a format useable by ca65 and missile command

#include <stdio.h>
#include <string>
 // consider piskel/*
//#include "/tmp/mc_mushrom.c"
#include "../piskel/mc_mushrom.c"
#include "../piskel/mbase.c"

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
// shift: pixels to shift to the right
// skip: the starting row in the frame data -- which you would use for example
// because there is blank space at the top the image data, no sense in encoding that
void generate(const char * name, 
              uint32_t * array, 
              int frames, 
              int rows, 
              int columns, 
              int skip, 
              int shift) 
{
  printf(".export %s_frames_shift%dL,%s_frames_shift%dH", name, shift,
         name,shift);
  for (int frame = 0; frame < frames; frame++) {
    printf(", ");
    printf("%s", make_name(name, frame, shift));
  }
  printf("\n.data\n");
  printf("%s_frames_shift%dL: .byte ", name, shift);
  for (int frame = 0; frame < frames; frame++) {
    if(frame)
      printf(", ");
    printf("<(%s)", make_name(name, frame, shift));
  }
  printf("\n%s_frames_shift%dH: .byte ", name, shift);
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
      bool solid_fill = false;
      for (int col = 0; col < columns; col++) {
        int pixel_offset = row * columns + col;
        // one byte per pixel?
        unsigned int *addr = (array + (frame * rows * columns) + pixel_offset);
        int val = *addr;
        // piskel writes ff for each on bit in the top two nybbles
        // we build a regular byte by shifting into it
        dword <<= 1;
        if (val & 0xff000000) {
          printf("\u2588");
          dword |= 1;
        } else {
          printf(" ");
        }
        // if any pixel int has low bit set
        if(val & 0x01 == 1) {
          solid_fill = true;
        }
        //fprintf(stderr,"[%d][%d] (%x) - %u:%x\n",frame, pixel_offset,addr, val?1:0,dword);
      }
      // shift one more byte to left so we have 1 byte more than the width
      // e.g. 16 wide sprite is 3 bytes, so we can subsequently pre-shift it by
      // 0-7 bits for performance in the generated assembly
      unsigned int a,b,c=0;
      a=dword;
      // 24 bit sprites are not preshiftable with this tech, so we skip the left shit
      if(columns<16)
        dword <<= 8;
      b=dword;
      // use 1 bit as code to set background to on, instead of off by default
      if(solid_fill) {
        // top bit is signal to the final shift loop
        // for background set to on
        dword|=0xff0000ff;
        c=dword;
      }
      dword>>=shift;
      char buf[255];
      /* sprintf(buf,"%06x,%06x,%06x,%06x", */
      /*         a&0x00ffffff, */
      /*         b&0x00ffffff, */
      /*         c&0x00ffffff, */
      /*         dword&0x00ffffff); */
      for (auto & c: buf) c = toupper(c);
      dwords[row] = dword;
      sprintf(buf,"%06x", dword & 0x00ffffff);
      printf("| $%s\n", buf);
    }
    // shift the sprite bytes we recorded
    for (int row = skip; row < rows; row++) {
      const unsigned int dword = dwords[row];
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

  // these are the hex X locations of the start of the cities currently
  // 08 20 38 6c  84 9c
  // city 0,1,2 = offset 1
  // city 3,4,5 = offset 5
  // add 9 to each of them to get the mushroom cloud centerline
  // because 9 is what the icbm target.  See icbm.asm:city_centerline equate
  const int city_centerline = 9;
  generate("mushroom",
           (unsigned int*)&mc_mushrom_data,
           MC_MUSHROM_FRAME_COUNT,
           MC_MUSHROM_FRAME_HEIGHT,
           MC_MUSHROM_FRAME_WIDTH,
           5, /* start row */
           (0x8 + city_centerline)%8 /* shift amount */
  );
  generate("mushroom",
           (unsigned int*)&mc_mushrom_data,
           MC_MUSHROM_FRAME_COUNT,
           MC_MUSHROM_FRAME_HEIGHT,
           MC_MUSHROM_FRAME_WIDTH,
           5, /* start row */
           (0x6c + city_centerline)%8 /* shift amount */
           );
  generate("mbase", 
           (unsigned int*)&missile_base_data,
           MISSILE_BASE_FRAME_COUNT,
           MISSILE_BASE_FRAME_HEIGHT,
           MISSILE_BASE_FRAME_WIDTH,
           0, /* start row */
           0  /* shift amount */
           );

  //generate(x,2,2,2);
}
// xterm
//- Move the cursor up N lines:
//  \033[<N>A
