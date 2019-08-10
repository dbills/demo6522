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
          ;; integer 'bresenham' like
          ;; line drawing routine
          ;; 1 = short axis line length
          ;; 2 = long axis line length
          ;; for 1 or 2, e.g. dx or dy
          ;; shift is when the short axis
          ;; must 'shift' due to the error
          ;; rate getting too high
          ;; inputs: Y = current long axis
          ;; position
          mac increment_long_axis
          add err, {1}
          cmp {2}
          bcc .noshift
          dex
          sub err,{2}
.noshift
          dey
          endm

genline   subroutine
          calc_dydx
          ;; dy is in A
          cmp dx
          bcc .line2                     ;dx>dy
          jsr line1
          jsr render1
          rts
.line2
          jsr line2
          jsr render2
          rts

line1     subroutine
          calc_dydx
          tay                           ;y=dy
          ldx x2                        ;x=x2
.loop                                   ;while(y>0)
          txa
          sta (lstore),y                ;lstore[y]=x
          increment_long_axis dx,dy
          bne .loop                     ;
          rts

line2     subroutine
          calc_dydx
          ldy dx                        ;y=dx
          ldx y2                        ;x=y2
.loop                                   ;while(y>0)
          txa
          sta (lstore),y                ;lstore[y]=x
          increment_long_axis dy,dx
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
