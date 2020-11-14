.INCLUDE  "screen.inc"
.include "zerop.inc"
.exportzp _x1,_x2,_y1,_y2,_lstore,_dx,_dy
.export _genline
          ;; public line symbols
          ;; line* routines put the 'line instructions' in ram
          ;; render* routines take a line instruction set and
          ;; place on the screen
          ;; private line symbols
.ZEROPAGE
err:      .res 1
_dx:       .res 1
_dy:       .res 1
_x1:       .res 1
_x2:       .res 1
_y1:       .res 1
_y2:       .res 1
_lstore:   .res 2
.CODE

          ;; inputs A=_dx
          ;; _x1>_x2
          ;; figure out if we are drawing in 2 or 4
.macro    quadrant_2or4
          .local dxline
          cmp _dy
          bcs dxline                   ;_dx>_dy
          jsr line3
          jsr render1
          rts
dxline:   
          jsr line4
          jsr render4
.endmacro
          ;; _x1<_x2
          ;; inputs A=_dx
          ;; figure out if we are drawing in 1 or 3
.macro    quadrant_1or3
          .local dxline
          cmp _dy
          bcs dxline                   ;_dx>_dy
          jsr line1
          jsr render1
          rts
dxline:   
          jsr line2
          jsr render2
.endmacro

.macro    calcdy
          lda _y2                        ;_dy=_y2-_y1+1
          sec
          sbc _y1
          adc #0    
          sta _dy                       
.endmacro

          ;; calculate _dy,dx and err for
          ;; a line
          ;; inputs: _x1,_x2,_y1,_y12
          ;; outputs: _dy,dx,err
          ;; A=_dy on exit
          ;; preconditions: _y2>_y1
.proc     _genline
          lda #0                        ;err=0
          sta err

          calcdy
          lda _x2                        ;dx=_x2-_x1+1
          sec
          sbc _x1
          bcs normal                   ;_x2<_x1
reversed:
          eor #$ff                      ;switch to _x1-_x2
          ;; we need to add 1 to finish our little 2's complement
          ;; stunt and get to _x1-_x2 -- and we also 
          ;; need to add +1 to dx, so
          ;; clc implied
          adc #2                        ;
          sta _dx                     
          quadrant_2or4
          rts
normal:   
          adc #0                        ;C is set dx+=1
          sta _dx                      
          quadrant_1or3
          rts
.endproc
          ;; sets up input for genline
          ;; linevars(_x1,_x2,_y1,_y2)
.macro    linevars __x1,__x2,__y1,__y2
          lda #__x1
          sta _x1
          lda #__x2
          sta _x2

          lda #__y1
          sta _y1
          lda #__y2
          sta _y2
.endmacro

.proc     test1
          ;; lda #175
          ;; sta pl_x
          ;; sta pl_y
          ;; lda #1
          ;; jsr plot
          linevars $ae,$87,$00,$25
                                        ;          TODO movi ldata1-1,lstore          
          jsr _genline
loop:     
          jmp loop
          rts
.endproc
          ;; integer 'bresenham' like
          ;; line drawing routine
          ;; 1 = short axis line length
          ;; 2 = long axis line length
          ;; 3 inx or dex 
          ;; for 1 or 2, e.g. dx or _dy
          ;; shift is when the short axis
          ;; must 'shift' due to the error
          ;; rate getting too high
          ;; inputs: Y = current long axis
          ;; position
.macro    increment_long_axis saxis,laxis,op
          .local shift
          lda err
          clc 
          adc saxis
          bcs shift
          sta err
          cmp laxis
          bcc noshift                   ;TODO optimize
          beq noshift
shift:    
          sec
          sbc laxis
          sta err
          op
noshift:
.endmacro
;;; note: diagonals don't end up here
;;; lstore: pointer to line storage
.proc     line1
          ldy _dy
          ldx _x2                        ;x=_x2
loop:                                   ;while(y>0)
          increment_long_axis _dx,_dy,dex
          txa
          sta (_lstore),y                ;lstore[y]=x
          dey
          bne loop
          rts
.endproc
;;; note: diagonal lines fall here
;;; dx>_dy
.proc     line2 
          ;; might be able to replace below with tay
          ldy _dx                        ;y=dx
          ldx _y2                        ;x=_y2
loop:                                   ;while(y>0)
          increment_long_axis _dy,_dx,dex
          txa
          sta (_lstore),y                ;lstore[y]=x
          dey
          bne loop                     ;
          rts
.endproc
;;; _dy>dx and _x2<_x1
;;; lstore: pointer to line storage
.proc     line3
          ldy _dy
          ldx _x2                        ;x=_x2
loop:                                   ;while(y>0)
          txa
          sta (_lstore),y                ;lstore[y]=x
          increment_long_axis _dx,_dy,inx
          dey
          bne loop
          rts
.endproc
;;; dx>_dy and _x2<_x1
;;; diagonals come in here
.proc     line4
          ldy _dx                        ;y=dx
          ldx _y1                        ;x=_y2
loop:                                   ;while(y>0)
          increment_long_axis _dy,_dx,inx
          txa
          sta (_lstore),y                ;lstore[y]=x
          dey
          bne loop                     ;
          rts
.endproc
          ;; inputs: _dy,_y2
.proc     render1
          ldy _dy
          ldx _y2
loop:     
          lda (_lstore),y
          sta _pl_x
          stx _pl_y
          dex       
          jsr _plot
          dey
          bne loop
          rts
.endproc
;;; dx>_dy line
.proc     render2
          ldy _dx
          ldx _x2
loop:     
          lda (_lstore),y
          sta _pl_y
          plotm txa
          dex
          dey
          bne loop
          rts
.endproc
.proc     render4
          ldy _dx
          ldx _x1
loop:     
          lda (_lstore),y
          sta _pl_y
          plotm txa
          dex
          dey
          bne loop
          rts
.endproc

.export XBMASKS_OFFSET_TBL, XBMASKS_0,XBMASKS_1,XBMASKS_2,XBMASKS_3,XBMASKS_4,XBMASKS_5,XBMASKS_6,XBMASKS_7
.DATA
XBMASKS_OFFSET_TBL: 
          .byte 8
          .byte 15
          .byte 21
          .byte 26
          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 15
          .byte 21
          .byte 26
          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 21
          .byte 26
          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 26
          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 33
          .byte 35
          .byte 0

          .byte 35
          .byte 0

          .byte 0

XBMASKS_0:
          .byte %10000000
          .byte %11000000
          .byte %11100000
          .byte %11110000
          .byte %11111000
          .byte %11111100
          .byte %11111110
          .byte %11111111
XBMASKS_1:          
          .byte %1000000
          .byte %1100000
          .byte %1110000
          .byte %1111000
          .byte %1111100
          .byte %1111110
          .byte %1111111
XBMASKS_2:          
          .byte %100000
          .byte %110000
          .byte %111000
          .byte %111100
          .byte %111110
          .byte %111111
XBMASKS_3:          
          .byte %10000
          .byte %11000
          .byte %11100
          .byte %11110
          .byte %11111
XBMASKS_4:          
          .byte %1000
          .byte %1100
          .byte %1110
          .byte %1111
XBMASKS_5:          
          .byte %100
          .byte %110
          .byte %111
XBMASKS_6:          
          .byte %10
          .byte %11
XBMASKS_7:          
          .byte %1

