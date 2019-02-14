#include <stdio.h>

/*
  some doodling in C to help me understand
  a line drawing algo that might work for me
*/

main() {
  printf("enter x x1 y y1\n");
  int x,x1,y,y1;
  scanf("%d%d%d%d",&x,&x1,&y,&y1);
  int dy = y1-y;
  int dx = x1-x;

  int n = dy/2;
  int e = 0;

  // down and to the right
  // for each dy dx/dy is summed
  // when we git .5 dx/dy we move to the right
  for(;y<y1;y++) {
    e+=dx;
    if(e>n) {
      x++;
      e=0;
    }
    printf("%3d,%3d\n",x,y);
  }
}
