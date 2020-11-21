#include "line.h"
#include "zerop.h"
#include <stdlib.h>
#include <unistd.h>

#define YMAX 175
#define XMAX 175
const unsigned char INTERCEPTED = -1;
#define LINE_DATA_MAX YMAX+1

typedef unsigned char uchar;
typedef struct  {
  uchar x1,x2,y1,y2,dx,dy;
  uchar line_points[LINE_DATA_MAX];
  uchar sentinel;
  void(*f)();
} line;

typedef struct {
  // offset in line pixel data
  line line_data;
  uchar altitude;
} missile;

missile missiles[5];

unsigned char ldata1[LINE_DATA_MAX];
extern char pl_x,pl_y;
#pragma zpsym("pl_x");
#pragma zpsym("pl_y");
extern void plot();
#define ST 0
#define ED 5

static void doom() {
  while(1) {
    *((char*)0x900f) = 255;
  }
}

static void sentinel() {
  int i;
  for(i=0;i < sizeof(missiles)/sizeof(missile);++i) {
    missiles[i].line_data.line_points[LINE_DATA_MAX-1]=42;
  }
}
static void check_sentinel() {
  int i;
  for(i=0;i < sizeof(missiles)/sizeof(missile);++i) {
    if(missiles[i].line_data.line_points[LINE_DATA_MAX-1]!=42)
      doom();
  }
}
static void delay() {
  unsigned int i,j;
  j = 0;
  for(i = 0;i < 500;++i) {
//    for(j = 0;j < 65535;++j) {
//    }
  }
}
static void lineto(uchar ix1, uchar iy1, uchar ix2, uchar iy2)
{
  x1 = ix1;
  x2 = ix2;
  y1 = iy1;
  y2 = iy2;
  lstore = ldata1;
  genline();
  (*p_render)();
}
static void lplot(uchar x1, uchar y1) 
{
  pl_x = x1;
  pl_y = y1;
  plot();
}
void c_main() {
  unsigned char i;
  for(i=0;i<175;i+=7) {
    lineto(i,0,i,175);
  }
//  lineto(0,0,175,175);
//  lineto(172,0,172,175);
//  lineto(170,0,170,175);
//  lplot(169,0);
//  lplot(173,0);
  lplot(175,0);
#if 0  
  int i;
  sentinel();
  // precal missiles
  for(i=ST;i<ED;++i) {
    y1=0;
    y2=YMAX;
    x1 = rand() % XMAX;
    x2 = rand() % XMAX;

    missiles[i].line_data.x1 = x1;
    missiles[i].line_data.x2 = x2;
    missiles[i].line_data.y1 = y1;
    missiles[i].line_data.y2 = y2;
    lstore = missiles[i].line_data.line_points;
    genline();

    if(dx >= LINE_DATA_MAX ||
       dy >= LINE_DATA_MAX) {
      doom();
    }

    missiles[i].line_data.dx = dx;
    missiles[i].line_data.dy = dy;
    missiles[i].line_data.f = p_render;
  }

  check_sentinel();

  // draw the missiles
  for(i=ST;i<ED;++i) {
    x1 = missiles[i].line_data.x1;
    x2 = missiles[i].line_data.x2;
    y1 = missiles[i].line_data.y1;
    y2 = missiles[i].line_data.y2;
    dx = missiles[i].line_data.dx;
    dy = missiles[i].line_data.dy;

    if(dx >= LINE_DATA_MAX ||
       dy >= LINE_DATA_MAX) {
      doom();
    }

    lstore = missiles[i].line_data.line_points;
    (*missiles[i].line_data.f)();
  }
  delay();
#endif
}

