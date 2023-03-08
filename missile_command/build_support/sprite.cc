// -*- compile-command: "g++-8 -std=c++17 sprite.cc -lm && ./a.out explosion data 8 0" -*-
// generate sprites data
// x^2+y^2=r^2
// x^2=r^2-y^2
// x = sqr(r^2-y^2)
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>
using namespace std;
unsigned char vbytes[3][16];
const int bit_count = 16;
static int shift = 0;

int mode = 0;
void output_pixel(int bit) {
    if(!mode) {
        printf("\u2588");
    }
}
void output_blank(int bit) {
    if(!mode) {
        printf(" ");
    }
}

void usage(const char *const progname) {
    fprintf(stderr,"usage: %s name <templ|data|print|collision> <radius> shift\n", progname);
    fprintf(stderr,"templ = inline code to draw sprite");
    exit(1);
}

int main(int argc, char **argv) {
    if(argc!=5)
        usage(argv[0]);
    const auto label_name = argv[1];
    const auto arg1 = std::string(argv[2]);
    if(arg1 == "print")
        mode = 0;
    else if(arg1 == "data")
        mode = 1;
    else if(arg1 == "templ") 
        mode = 2;
    else if(arg1 == "collision") 
        mode = 3;
    else 
        usage(argv[0]);

    const double r=atoi(argv[3]);
    shift = atoi(argv[4]);
    const int radius = bit_count /2;
    int row, col;
    if(!mode)
        printf("765432107654321076543210\n");
    int lower_bound, upper_bound;
    if(!mode) {
        lower_bound = -7;
        upper_bound = 8;
    } else {
        lower_bound = -r + 1;
        upper_bound = r;
    }
    for(int y=lower_bound; y < upper_bound; y++) {
        // solve for X in circle equation
        double _x = sqrt(pow(r,2) - pow(y, 2));
        int x = round(_x);         //int x = floor(_x);
        unsigned char byte = 0;
        // output the picture of this row, and build the bytes for it
        for(int i = -7;i <= 16;i++) {
            // is this bit 'inside' the x coords for this line of the circle?
            if((i - shift > -x) && (i - shift < x)) {
                output_pixel(i);
                byte |= 1;
            } else {
                output_blank(i);
            }
            row = y + r - 1;
            if(i % 8 == 0) {    // on even byte, we store in array for later
                col = (i + 7) / 8;
                vbytes[col][row] = byte;
                byte = 0;
            } else {
                byte <<= 1;
            }
        }
        if(!mode) {
            printf("$%2x: $%02x,$%02x,$%02x",(char)row,vbytes[0][row],vbytes[1][row],vbytes[2][row]);
            printf("\n");
        }
    }
    // this mode is only useful for offset 0
    // thus we assume 2 bytes only needed
    if(mode == 3) {
        const int height = (int)r * 2 - 1;
        printf(".export %s_%1.0f_shift%d\n",argv[1],r,shift);
        printf("%s_%1.0f_shift%d:\n",argv[1],r,shift);
        int pr = 0;
        for(int row=-7;row<8;row++) {
            printf("     .byte ");
            if(row>-r) {
                for(int col = 0,first=1;col < 2; col++) {
                    for(int i=0;i<8;i++) {
                        unsigned char bitval = (unsigned char)(pow(2,7-i));
                        if(!first) {
                            printf(",");
                        }
                        first=0;
                        if(vbytes[col][pr] & bitval) {
                            printf("01");
                        } else {
                            printf("00");
                        }
                    }
                }
                pr++;
            } else {
                for(int i=0;i<16;i++) {
                    if(i)
                        printf(",");
                    printf("00");
                }
            }
            printf(" ;; %02d\n",row+7);
        }
    }
    if(mode == 1) {
        const int height = (int)r * 2 - 1;
        printf("%s_%1.0f_shift%d:\n",argv[1],r,shift);
        printf(".export %s_%1.0f_shift%d\n",argv[1],r,shift);
        printf("  .byte $%x\n", height);
        for(int col = 0;col < 3; col++) {
            printf(".export %s_%1.0f_shift%d_strip%d\n", argv[1], r, shift, col);
            printf("%s_%1.0f_shift%d_strip%d:\n", argv[1], r, shift, col);
            for(int row=0;row<height;row++) {
                printf("  .byte $%02x\n", vbytes[col][row]);
            }
        }
    } else if(mode == 2) {
        const char *const indent = "          ";
        int height = (int) r * 2 - 1;
        printf(".export draw_%s_%1.0f_shift%d\n", argv[1], r, shift);
        printf(".proc draw_%s_%1.0f_shift%d\n", argv[1], r, shift);
        /*
        for(int i = 0;i < 3; i++) {
            printf("%slda pltbl+%d,x\n", indent,i*2);
            printf("%ssta sp_col%d\n", indent, i);
            printf("%slda pltbl+%d,x\n", indent, i*2+1);
            printf("%ssta sp_col%d+1\n", indent, i);
        }
        */
        printf("\n");
        for(int row = 0;row < height; row++) {
            for(int col = 0;col < 3; col++) {
                const int v = vbytes[col][row];
                if(v) {
                    printf("%slda (sp_col%d),y\n",indent,col);
                    printf("%seor #$%02x\n",indent,vbytes[col][row]);
                    printf("%ssta (sp_col%d),y\n", indent, col);
                } else {
                    printf("%s;;nop\n", indent);
                }
            }
            if(row < height - 1)
                printf("%siny\n", indent);
        }
        printf("%srts\n", indent);
        printf(".endproc\n");
    }
}
