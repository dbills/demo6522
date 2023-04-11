// convert sprite data exported from the inline sprite editor 'piskel'
// into a format useable by ca65 and missile command

#define NEWCODE 

#include <stdio.h>
#include <string>
 // consider piskel/*
//#include "/tmp/mc_mushrom.c"
#include "../piskel/mc_mushrom.c"
#include "../piskel/missile_base.c"
#include "../piskel/mc_city.c"
#include "../piskel/mc_explosion.c"
#include "../piskel/k_sat.c"
#include "../piskel/mc_bomb.c"

#include <strings.h>

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
  printf("  lda (sp_col%d),y\n", screen_col);
  printf("  eor #$%02x\n", b);
  printf("  sta (sp_col%d),y\n", screen_col);
}

char g_name[256];
const char * make_name(const char * name, int frame, int shift) {
  sprintf(g_name, "%s%d_shift%d", name, frame, shift);
  return g_name;
}
void  auto_calc_offsets(uint32_t *array, 
                        int frames, 
                        int columns, 
                        int rows,
                        int skip_offsets[], 
                        int rows_to_show[]) 
{
  for (int frame = 0; frame < frames; frame++) {
    int skip_offset = 0, row_to_show = 0;
    for (int row = 0;row<rows;++row) {
      int val=0;
      for (int col = 0; col < columns; col++) {
        int pixel_offset = row * columns + col;
        unsigned int *addr = (array + (frame * rows * columns) + pixel_offset);
        val |= *addr;
      }
      if(!skip_offset && val)
        skip_offset=row-1;
      if(val)
        row_to_show=row;
    }
    skip_offsets[frame]=skip_offset>=0?skip_offset:0;
    rows_to_show[frame]=row_to_show-skip_offsets[frame]+1;
  }
}
// C is row-major order
// x[r][c]
// shift: pixels to shift to the right
// skip: the starting row in the frame data -- which you would use for example
// because there is blank space at the top the image data, no sense in encoding that
// skip_offsets = array of starting positions for each frame
// rows_to_show = array of row to show for each frame
//                e.g. if skip =3 and rows_to_show=3
//                then that frame shows rows 3-6 in the sprite definition
void generate(const char * name, 
              uint32_t * array, 
              int frames, 
              int columns, 
              int rows, 
              int *skip_offsets, 
              int *rows_to_show,
              int shift,
              int eor=0,
              int collision=0,
              int emit_frame_data=1
              ) 
{
  if(emit_frame_data) {
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
  }
  printf(".code\n");
  for (int frame = 0; frame < frames; frame++) {
    printf(".export %s\n", make_name(name, frame, shift));
    printf(".proc %s\n", make_name(name, frame, shift));
    printf(";;;     7654321+76543210\n");
    unsigned int dwords[rows];
    bzero(dwords,sizeof(dwords));
    for (int row = skip_offsets[frame],row_counter=0; 
         row < rows && (rows_to_show[frame]==-1 ||
                        row_counter < rows_to_show[frame]);
         ++row,++row_counter) {
      printf("  ;;%c%2d|", row==(rows/2)?'+':' ', row);
      unsigned int dword = 0;
      bool solid_fill = false;
      for (int col = 0; col < columns; col++) {
        int pixel_offset = row * columns + col;
        // one byte per pixel
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
      // 24 bit sprites are not preshiftable with this tech, so we skip the left shift
      if(columns<=16)
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
#ifdef NEWCODE
    int row_counter,row;
    int ub = rows_to_show[frame]==-1 ? rows -1 : 
      rows_to_show[frame] + skip_offsets[frame] - 1;
    int lb = skip_offsets[frame];
    printf(";; [%d,%d]\n.data\n",lb, ub);
    if(shift>0 || columns>16) {
      printf("row3:\n  .byte ");
      for (row = ub, row_counter = 0; row >= lb; --row, ++row_counter) {
        printf("%s$%02x", (row_counter ? "," : ""), B1(dwords[row]));
      }
      printf("\n");
    }
    printf("row2:\n  .byte ");
    for (row = ub, row_counter = 0; row >= lb; --row, ++row_counter) {
      printf("%s$%02x", (row_counter ? "," : ""), B2(dwords[row]));
    }
    printf("\n");
    printf("row1:\n  .byte ");
    for (row = ub, row_counter = 0; row >= lb; --row, ++row_counter) {
      printf("%s$%02x", (row_counter ? "," : ""), B3(dwords[row]));
    }
    printf("\n");
    printf("\n.code\n  txa\n  pha\n");
    printf("  ldx #$%02x\n",(unsigned char)(row_counter - 1));
    printf("loop:\n");
    // eor
    printf("  lda row1,x\n");
    if(eor) printf("  eor (sp_col0),y\n");
    // write
    printf("  sta (sp_col0),y\n");
    // eor 1
    printf("  lda row2,x\n");
    if(eor) printf("eor (sp_col1),y\n");
    // write 1
    printf("  sta (sp_col1),y\n");
    if(shift>0||columns>16) {
      // eor 2
      printf("\n  lda row3,x\n");
      if(eor)
        printf("\n  eor (sp_col2),y\n");
      // write 2
      printf("  sta (sp_col2),y\n");
    }
    printf("\
  iny\n\
  dex\n\
  bpl loop\n");
#endif
    // shift the sprite bytes we recorded
    // only emit number of rows requested for this frame
    for (int row = skip_offsets[frame],row_counter=0; 
         row < rows && (rows_to_show[frame]==-1 ||
                        row_counter < rows_to_show[frame]);
         ++row) {
      const unsigned int dword = dwords[row];
      unsigned char b3 = B3(dword);
      unsigned char b2 = B2(dword);
      unsigned char b1= B1(dword);
#ifndef NEWCODE
      if(b3)
        write_byte(b3, 0);
      if(b2)
        write_byte(b2, 1);
      if(shift>0 || columns>16) {
        if(b1)
          write_byte(b1, 2);
      }
      if (row < rows - 1) {
        if(b1 || b2 || b3) {
          printf("  iny\n");
        }
      }
#else
#endif
      ++row_counter;
    }
    printf("  pla\n  tax\n");
    printf("  rts\n.endproc\n\n");
    printf(".data\n");
    if( collision && shift==0) {
      printf(".export collision_%s\n", make_name(name, frame, shift));
      printf("collision_%s:\n", make_name(name, frame, shift));
      for (int row = 0;row < rows; ++row){
          unsigned int dword = dwords[row]<<8;
          printf(".byte %%");
          for(int i=0,counter=0;i < 8;++i,++counter) {
            //printf("%s$%02X", (counter ? "," : ""), (dword&0x80000000) ? 255:0);
            printf("%c", (dword&0x80000000) ? '1':'0');
            dword<<=1;
          }
          printf(",%%");
          for(int i=0,counter=0;i < 8;++i,++counter) {
            //printf("%s$%02X", (counter ? "," : ""), (dword&0x80000000) ? 255:0);
            printf("%c", (dword&0x80000000) ? '1':'0');
            dword<<=1;
          }
          printf(" ;; %d\n", row);
        }
    }
    printf(".code\n");

  }
}

int main(int argc, char ** argv) {
  printf(".include \"zerop.inc\"\n");
  /* int *p = (int*)x; */
  /* int r=1; */
  /* int c=2; */
  /* printf("%d,%d\n", x[r][c],*(p+(r*3)+c)); */

  const int city_centerline = 9;
  int skip_offsets[25];
  int rows_to_show[25];
  for(int i=0;i<25;++i) {
    skip_offsets[i]=0;
    rows_to_show[i]=-1; // show them all
  }
#if 1
  for(int i=0;i<MC_MUSHROM_FRAME_COUNT;++i) {
    skip_offsets[i]=6;
    rows_to_show[i]=-1; // show them all
  }
  generate("mushroom",
           (unsigned int*)&mc_mushrom_data,
           MC_MUSHROM_FRAME_COUNT,
           MC_MUSHROM_FRAME_WIDTH,
           MC_MUSHROM_FRAME_HEIGHT,
           skip_offsets, /* start rows per frame */
           rows_to_show,
           0 /* shift amount */
  );
  // shift 4, to align with missile base explosion
  /* generate("mushroom", */
  /*          (unsigned int*)&mc_mushrom_data, */
  /*          MC_MUSHROM_FRAME_COUNT, */
  /*          MC_MUSHROM_FRAME_WIDTH, */
  /*          MC_MUSHROM_FRAME_HEIGHT, */
  /*          skip_offsets, /\* start rows per frame *\/ */
  /*          rows_to_show, */
  /*          4 /\* shift amount *\/ */
  /* ); */
  int base_skip_offsets[MISSILE_BASE_FRAME_COUNT] =
    { 0,           // full sprite
      13,13,13,13, // erase bottom 4 interceptors
      9,9,9,       // erase next 3
      5,5,         // erase 2
      2            // erase top
    };
  int base_rows_to_show[MISSILE_BASE_FRAME_COUNT] =
    { -1, // 10
      3, // 9 bottom
      3, // 8 "
      3, // 7 "
      3, // 6 "
      3, // 5 middle
      3, // 4 "
      3, // 3 "
      3, // 2 upper-middle
      3, // 1 "
      3, // 0 top
    };
                                                     
  generate("mbase",
           (unsigned int*)&missile_base_data,
           MISSILE_BASE_FRAME_COUNT,
           MISSILE_BASE_FRAME_WIDTH,
           MISSILE_BASE_FRAME_HEIGHT,
           base_skip_offsets, /* start row */
           base_rows_to_show,
           0  /* shift amount */
           );

  for(int i=0;i<25;++i) {
    skip_offsets[i]=0;
    rows_to_show[i]=-1; // show them all
  }
  generate("mcity",
           (unsigned int*)&mc_city_data,
           MC_CITY_FRAME_COUNT,
           MC_CITY_FRAME_WIDTH,
           MC_CITY_FRAME_HEIGHT,
           skip_offsets, /* start row */
           rows_to_show,
           0  /* shift amount */
           );
#endif
  auto_calc_offsets((unsigned int*)&mc_explosion_data,
                    MC_EXPLOSION_FRAME_COUNT,
                    MC_EXPLOSION_FRAME_WIDTH,
                    MC_EXPLOSION_FRAME_HEIGHT,
                    skip_offsets, rows_to_show);
  printf(".data\n");
  printf(".export explosion_frame_skip_offsets\n");
  printf("explosion_frame_skip_offsets:\n.byte ");
  for(int i=0;i<MC_EXPLOSION_FRAME_COUNT;++i) {
    printf("$%02x%s",skip_offsets[i],i==MC_EXPLOSION_FRAME_COUNT-1?"":",");
  }
  /* printf("\nexplosion_frame_rows:\n.byte "); */
  /* for(int i=0;i<MC_EXPLOSION_FRAME_COUNT;++i) { */
  /*   printf("$%02x%s",rows_to_show[i],i==MC_EXPLOSION_FRAME_COUNT-1?"":","); */
  /* } */
  printf("\n.code\n");
  for(int i=0;i<8;i++) {
    generate("draw_explosion_",
             (unsigned int*)&mc_explosion_data, 
             MC_EXPLOSION_FRAME_COUNT,
             MC_EXPLOSION_FRAME_WIDTH,
             MC_EXPLOSION_FRAME_HEIGHT,
             skip_offsets,      /* start row */
             rows_to_show,
             i,                 /* shift amount */
             1,                 /* perform exclusive or */
             1                  /* emit collision data */
             );
  }

  int ksat_skip_offsets[K_SAT_FRAME_COUNT] =
    { 0, 0  };
  int ksat_rows_to_show[K_SAT_FRAME_COUNT] =
    { 14,14 };
  for(int i=0;i<8;i++) {
    generate("ksat_",
             (unsigned int*)&k_sat_data, 
             K_SAT_FRAME_COUNT,
             K_SAT_FRAME_WIDTH,
             K_SAT_FRAME_HEIGHT,
             ksat_skip_offsets, /* start row */
             ksat_rows_to_show,
             i,                 /* shift amount */
             1,                 /* perform exclusive or */
             1,                 /* no collision data */
             0                  /* no frame data */
             );
  }

  int mcb_skip_offsets[MCJETBOMBER_FRAME_COUNT] =
    { 0, };
  int mcb_rows_to_show[MCJETBOMBER_FRAME_COUNT] =
    { 16 };
  for(int i=0;i<8;i++) {
    generate("bomber",
             (unsigned int*)&mcjetbomber_data, 
             MCJETBOMBER_FRAME_COUNT,
             MCJETBOMBER_FRAME_WIDTH,
             MCJETBOMBER_FRAME_HEIGHT,
             mcb_skip_offsets, /* start row */
             mcb_rows_to_show,
             i,                 /* shift amount */
             1,                 /* perform exclusive or*/
             1,                 /* no collision data */
             0                  /* no frame data */
             );
  }
}
// xterm
//- Move the cursor up N lines:
//  \033[<N>A
