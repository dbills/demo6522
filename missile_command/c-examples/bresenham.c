#include <stdio.h>
#include <assert.h>
#include <math.h>
#include <stdlib.h>

int log_base_b(int b, int n) {
  return log10(n) / log10(b);
}
void print_xaxis(int x1) {
  // skip over Y axis 
  printf("    ");
  int places = log10(x1);
  char labels[x1][places+1];
  for(int i=0;i<x1;i++) {
    sprintf(&labels[i][0], "%-3d", i+1);
    //printf("%s\n",&labels[i][0]);
  }
  //exit(0);
  for(int j=0;j<places+1;j++) {
    for(int i=0;i<x1;i++) {
        printf("%c",labels[i][j]);
    }
    printf("\n    ");
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
  print_xaxis(x1);
}
  

