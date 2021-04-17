// convert sprite data exported from the inline sprite editor 'piskel'
// into a format useable by ca65 and missile command

#include <stdio.h>
// consider piskel/*
#include "/tmp/mc_mushroom.c"

int mode = 0;
void output_pixel(int bit) {
    if(!mode) {
        printf("\u2588");
    }
}
// C is row-major order
// x[r][c]
void generate(uint32_t *array, int frames, int row_width, int column_height,int skip) {
  for(int frame=0;frame < frames; frame++) {
    for(int row=0;row < row_width; row++) {
      printf("%2d|",row);
      for(int col=0;col < column_height;col++) {
        int pixel_offset = row*row_width+col;
        int *addr = ( array +
                      (frame * row_width*column_height) +
                      pixel_offset);
        int val = *addr;
        //printf("[%d][%d] (%x) - %u\n",frame, pixel_offset,addr,val);
        if(val) {
          printf("\u2588");
        } else {
          printf(" ");
        }
      }
      printf("\n");
    }
  }
}

int main(int argc,char **argv) {
  /* int *p = (int*)x; */
  /* int r=1; */
  /* int c=2; */
  /* printf("%d,%d\n", x[r][c],*(p+(r*3)+c)); */
  generate(mc_mushrom_data,
           MC_MUSHROM_FRAME_COUNT,
           MC_MUSHROM_FRAME_WIDTH,
           MC_MUSHROM_FRAME_HEIGHT,
           16-11);
  //generate(x,2,2,2);
}
// xterm
//- Move the cursor up N lines:
//  \033[<N>A
