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
    if(mode) {
//        printf("1");
    } else {
        printf("\u2588");
    }
}
void output_blank(int bit) {
    if(mode) {
//        printf("0");
    } else {
        printf(" ");
    }
}

void usage(const char *const progname) {
    fprintf(stderr,"usage: %s name <data|print> <radius> shift\n", progname);
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
    else
        usage(argv[0]);
    const double r=atoi(argv[3]);
    shift = atoi(argv[4]);
    const int radius = bit_count /2;
    int row, col;
    if(!mode)
        printf("765432107654321076543210\n");
    for(int y=-r+1;y<r;y++) {
        double _x = sqrt(pow(r,2)-pow(y,2));
        //int x = floor(_x);
        int x = round(_x);
        unsigned char byte = 0;
        for(int i=-7;i<=16;i++) {
            if((i-shift>-x) && (i-shift<x)) {
                output_pixel(i);
                byte|=1;
            } else {
                output_blank(i);
            }
            row = y+r-1;
            if(i % 8 == 0) {
                col = (i + 7)/8;
                vbytes[col][row] = byte;
                byte = 0;
            } else {
                byte <<= 1;
            }
        }
        //fprintf(stderr,"\n");
        if(!mode) {
            printf("$%x: $%02x,$%02x,$%02x",row,vbytes[0][row],vbytes[1][row],vbytes[2][row]);
            printf("\n");
        }
    }
    if(mode) {
        int height = (int)r*2-1;
        printf("%s_%1.0f_shift%d:\n",argv[1],r,shift);
        printf("  .byte $%x\n", height);
        for(int col=0;col<3;col++) {
            printf("%s_%1.0f_shift%d_strip%d:\n",argv[1],r,shift,col);
            for(int row=0;row<height;row++) {
                printf("  .byte $%02x\n",vbytes[col][row]);
            }
        }
    }
}
