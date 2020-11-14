#include "line.h"
#include <stdlib.h>
const unsigned char INTERCEPTED = -1;
#define LINE_DATA_MAX 176

typedef unsigned char uchar;
typedef struct  {
  uchar dx,dy;
  uchar line_points[LINE_DATA_MAX];
} line;
typedef struct {
  // offset in line pixel data
  line line_data;
  uchar data_index;
} missile;

missile missiles[30];

unsigned char ldata1[255*3];
extern char pl_x,pl_y;
#pragma zpsym("pl_x");
#pragma zpsym("pl_y");
extern void plot();
void c_main() {
  int i;
  y1=0;
  y2=175;
  lstore = missiles[0].line_data.line_points;
  for(i=0;i<30;++i) {
    x1 = rand() % 176;
    x2 = rand() % 176;
    genline();
  }
  /*
  x1=50;
  y1=50;
  x2=100;
  y2=100;
  genline();
  */
}
