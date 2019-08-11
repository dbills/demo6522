          ;; public line symbols
;          include "line.equ"
          ;; private line symbols
          SEG.U     ZEROP
err       dc.b
dx        dc.b
dy        dc.b
          SEG       CODE

          ;; calculate dy,dx and err for
          ;; a line
          ;; inputs: x1,x2,y1,y12
          ;; outputs: dy,dx,err
          ;; A=dy on exit
          mac calc_dydx
          lda #0                        ;err=0
          sta err
          lda x2                        ;dx=x2-x1+1
          sec
          sbc x1
          adc #0                      
          sta dx                      
          lda y2                        ;dy=y2-y1+1
          sec
          sbc y1
          adc #0    
          sta dy                       
          endm

test1     subroutine
          lda #175
          sta pl_x
          sta pl_y
          lda #1
          jsr plot
          ;; lda #1
          ;; sta x1
          ;; lda #1
          ;; sta x2

          ;; lda #0
          ;; sta y1
          ;; lda #175
          ;; sta y2
          ;; mov_wi ldata1-1,lstore
          ;; jsr line1
          ;; jsr render1
.loop:     
          jmp .loop
          rts

borda     subroutine
          lda #$42
          rts

cdelta    subroutine
          calc_dydx
          rts
          ;; integer 'bresenham' like
          ;; line drawing routine
          ;; 1 = short axis line length
          ;; 2 = long axis line length
          ;; 3 inx or dex 
          ;; for 1 or 2, e.g. dx or dy
          ;; shift is when the short axis
          ;; must 'shift' due to the error
          ;; rate getting too high
          ;; inputs: Y = current long axis
          ;; position
          mac increment_long_axis
          lda err
          clc 
          adc {1}
          bcs .shift
          sta err
          cmp {2}
          bcc .noshift
          beq .noshift
.shift
          sec
          sbc {2}
          sta err
          {3}
.noshift
          endm

genline   subroutine
          calc_dydx
          ;; dy is in A
          cmp dx
          bcc .line2                     ;dx>dy
          jsr line1
          ;jsr render1
          rts
.line2
          jsr line2
          ;yjsr render2                   ;
          rts

line1     subroutine
          tay                           ;y=dy
          ldx x2                        ;x=x2
.loop                                   ;while(y>0)
          increment_long_axis dx,dy,dex
          txa
          sta (lstore),y                ;lstore[y]=x
          dey
          bne .loop
          rts

line2     subroutine
          ldy dx                        ;y=dx
          ldx y2                        ;x=y2
.loop                                   ;while(y>0)
          increment_long_axis dy,dx,dex
          txa
          sta (lstore),y                ;lstore[y]=x
          dey
          bne .loop                     ;
          rts

;;; cache the screen column pointer somehow
;;; if oldx!=x then recalc


;;; move Y down one line when drawing
;;; a dx>dy line
increment_y         subroutine
                    ldx xbmask_pidx
                    lda XBMASKS_OFFSET_TBL,x
                    sta xbmask_pidx
                    rts

render1   subroutine
          ldy dy
.loop
          lda (lstore),y
          sta pl_x
          sty pl_y
          jsr plot
          dey
          bne .loop
          rts
;;; dx>dy line
render2   subroutine
          ldy dx
.loop
          lda (lstore),y
          sta pl_y
          sty pl_x
          jsr plot
          dey
          bne .loop
          rts
