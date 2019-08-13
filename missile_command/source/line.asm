          ;; public line symbols
;          include "line.equ"
          ;; private line symbols
          SEG.U     ZEROP
err       dc.b
dx        dc.b
dy        dc.b
          SEG       CODE

          ;; inputs A=dx
          ;; x1>x2
          mac line_choice2
          cmp dy
          bcs .dxline                   ;dx>dy
          jsr line3
          jsr render1
          rts
.dxline
          jsr line4
          jsr render4
          endm
          ;; x1<x2
          ;; inputs A=dx
          mac line_choice
          cmp dy
          bcs .dxline                   ;dx>dy
          jsr line1
          jsr render1
          rts
.dxline
          jsr line2
          jsr render2
          endm

          mac calcdy
          lda y2                        ;dy=y2-y1+1
          sec
          sbc y1
          adc #0    
          sta dy                       
          endm

          ;; calculate dy,dx and err for
          ;; a line
          ;; inputs: x1,x2,y1,y12
          ;; outputs: dy,dx,err
          ;; A=dy on exit
          ;; preconditions: y2>y1
genline   subroutine
          lda #0                        ;err=0
          sta err

          calcdy
          lda x2                        ;dx=x2-x1+1
          sec
          sbc x1
          bcs .normal                   ;x2<x1
.reversed
          eor #$ff                      ;switch to x1-x2
          adc #2
          sta dx
          line_choice2
          rts
.normal
          adc #0                        ;C is set
          sta dx                      
          line_choice
          rts

          mac linevars
          lda #{1}
          sta x1
          lda #{2}
          sta x2

          lda #{3}
          sta y1
          lda #{4}
          sta y2
          endm

test1     subroutine
          ;; lda #175
          ;; sta pl_x
          ;; sta pl_y
          ;; lda #1
          ;; jsr plot
          linevars $ae,$87,$00,$25
          mov_wi ldata1-1,lstore
          jsr genline
.loop:     
          jmp .loop
          rts

borda     subroutine
          lda #$42
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
;;; note: diagonals don't end up here
;;; lstore: pointer to line storage
line1     subroutine
          ldy dy
          ldx x2                        ;x=x2
.loop                                   ;while(y>0)
          increment_long_axis dx,dy,dex
          txa
          sta (lstore),y                ;lstore[y]=x
          dey
          bne .loop
          rts
;;; note: diagonal lines fall here
;;; dx>dy
line2     subroutine
          ;; might be able to replace below with tay
          ldy dx                        ;y=dx
          ldx y2                        ;x=y2
.loop                                   ;while(y>0)
          increment_long_axis dy,dx,dex
          txa
          sta (lstore),y                ;lstore[y]=x
          dey
          bne .loop                     ;
          rts

;;; dy>dx and x2<x1
;;; lstore: pointer to line storage
line3     subroutine
          ldy dy
          ldx x2                        ;x=x2
.loop                                   ;while(y>0)
          txa
          sta (lstore),y                ;lstore[y]=x
          increment_long_axis dx,dy,inx
          dey
          bne .loop
          rts
;;; dx>dy and x2<x1
;;; diagonals come in here
line4     subroutine
          ldy dx                        ;y=dx
          ldx y1                        ;x=y2
.loop                                   ;while(y>0)
          increment_long_axis dy,dx,inx
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
          ldx y2
.loop
          lda (lstore),y
          sta pl_x
          stx pl_y
          dex       
          jsr plot
          dey
          bne .loop
          rts
;;; dx>dy line
render2   subroutine
          ldy dx
          ldx x2
.loop
          lda (lstore),y
          sta pl_y
          plotm txa
          dex
          dey
          bne .loop
          rts

render4   subroutine
          ldy dx
          ldx x1
.loop
          lda (lstore),y
          sta pl_y
          plotm txa
          dex
          dey
          bne .loop
          rts
