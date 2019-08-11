// -*- compile-command: "gcc bresenham.c -lm && ./a.out" -*-
#include <stdio.h>
#include <assert.h>
#include <math.h>
#include <stdlib.h>

void print_xaxis(int x1) {
  // skip over Y axis 
  printf("    ");
  int places = log10(x1);
  char labels[x1][places+1];
  for(int i=0;i<x1;i++) {
    sprintf(&labels[i][0], "%-3d", i+1);
  }
  for(int j=0;j<places+1;j++) {
    for(int i=0;i<x1;i++) {
        printf("%c",labels[i][j]);
    }
    printf("\n    ");
  }
}
// Quadrant 4 line, DY > DX
void quadrant4_acute(int x,int x1,int y,int y1,int *x_out, int *y_out) {
  int dy = y1-y+1;
  int dx = x1-x+1;
  printf("dx=%d dy=%d\n",dx,dy);

  int e = 0;

  for(;y<=y1;y++) {
    //printf("%*d,%3d\n",3,x,y);
    printf("%3d|%*c\n",y,x,'*');
    e+=dx;
    if(e>=dy) {
      x++;
      e-=dy;
    }
  }
}
typedef void (*n_operation)(int *);
void nplus(int *n) {
 (*n)++;
}
void nminus(int *n) {
 (*n)--;
}
int delta_n(int x1, int x2) {
  return abs(x2-x1)+1;
}
int max_n(int x1,int x2) {
  if(x1>x2) return x1;
  else return x2;
}
// Y is always the longaxis
// X is always the short axis 
void acute4_param(int x,int x1,int y,int y1,int *x_out, int *y_out, 
                  n_operation yop,
                  n_operation xop,
                  int dx,int dy) {
  printf("dx=%d dy=%d\n",dx,dy);

  int e = 0;

  for(;y<=y1;(*yop)(&y)) {
    //printf("%*d,%3d\n",3,x,y);
    printf("%3d|%*c\n",y,x,'*');
    e+=dx;
    if(e>=dy) {
      (*xop)(&x);
      e-=dy;
    }
  }
}
// assume 0,0 at upper left
// always make x operation be ++
// to accomplish a line with negative slope
// Y runs from bottom of line to top
// for a line with positive slope
// Y runs from top to bottom
void any_quadrant(int x,int x1,int y,int y1,int *x_out, int *y_out) {
  int dy = delta_n(y1,y);
  int dx = delta_n(x,x1);
  if(dy>dx) {
    if(y1>y) {
      if(x1>x) { 
        acute4_param(x,x1,y,y1,x_out,y_out,nplus,nplus,dx,dy);
      } else {
        acute4_param(x,x1,y,y1,x_out,y_out,nplus,nminus,dx,dy);
      }
    } else {
      // switch y,y1
      if(x1>x)
        acute4_param(x,x1,y1,y,x_out,y_out,nplus,nplus,dx,dy);
      else {
        acute4_param(x,x1,y1,y,x_out,y_out,nplus,nminus,dx,dy);
      }
    }
  } else {
    // X is the long axis
    if(y1>y) {
      printf("y1>y\n");
      if(x1>x) {
        printf("y1>y x1>x\n");
        acute4_param(y,y1,x,x1,y_out,x_out,nplus,nplus,dy,dx);
        } else {
        printf("y1>y x1<x\n");
        acute4_param(y1,y,x1,x,y_out,x_out,nplus,nminus,dy,dx);
      }
    } else {
      // switch y,y1 - 
      if(x1>x) {
        printf("y1<y x1>x\n");
        acute4_param(y,y1,x,x1,y_out,x_out,
                     nplus,     /* long axis op */
                     nminus,     /* short axis op */
                     dy,dx);
      } else {
        printf("y1<y x1<x\n");
        acute4_param(y1,y,x1,x,y_out,x_out,nplus,nplus,dy,dx);
      }
    } 
  }
}

/*
  some doodling in C to help me understand
  a line drawing algo that might work for me
*/

int main(int argc, char **argv) {
  printf("enter x x1 y y1\n");
  int x,x1,y,y1;
  scanf("%d%d%d%d",&x,&x1,&y,&y1);
  assert(x!=0 && x1!=0 && y!=0 && y1!=0);
  //quadrant4_acute(x,x1,y,y1,0,0);
  any_quadrant(x,x1,y,y1,0,0);
  print_xaxis(max_n(x,x1));
}
  

#if 0
there could be some kind of compression for obtuse lines?
with acute, were always moving one byte at a time on the raster map, and only flipping one bit on in the mask

with obtuse, we are saying from 1 to N where N<8 starting at offset O bits are on, turn them on and then move to the next byte
xxxxx
     xxxxx
          xxxxx

i could keep all of these bit patterns pre-made in memory; how many are there?
it is a sum of terms
let O = bit offset where 0 <= O <= 7
let N = length of bits
where N < 8-O
x
 x
  x
   x

   x
  x
 x
x


#endif
