#ifndef _line_h
#define _line_h
extern void genline();
extern void render1();
extern void render2();
extern void render4();
extern void(*p_render)();
extern unsigned char x1,x2,y1,y2,dx,dy;
extern unsigned char *lstore;
#pragma zpsym("x1");
#pragma zpsym("y1");
#pragma zpsym("x2");
#pragma zpsym("y2");
#pragma zpsym("dx");
#pragma zpsym("dy");
#pragma zpsym("lstore");
#endif
