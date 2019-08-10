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
          ;; 2 = long axies line length
          ;; for 1 or 2, e.g. dx or dy
          ;; shift is when the short axis
          ;; must 'shift' due to the error
          ;; rate getting too high
          ;; inputs: Y = current long axis
          ;; position
          mac increment_long_axis
.loop
          add err, {1}
          cmp {2}
          bcc .noshift
          dex
          sub err,dy
.noshift
          dey
          endm

t1        subroutine
          
          rts

line1     subroutine
          calc_dydx
          tay                           ;y=dy
          ldx x2                        ;x=x2
.loop                                   ;while(y>0)
          txa
          sta (lstore),y                ;lstore[y]=x
          add err,dx                    ;err+=dx
          cmp dy                        ;if(err<dy)
          bcc .noshift                  ;{
          dex                           ;  x--
          sub err,dy                    ;  err-=dx
.noshift                                ;}
          dey
          bne .loop                     ;
          rts

line2     subroutine
          calc_dydx
          ldy dx                        ;y=dx
          ldx y2                        ;x=y2
.loop                                   ;while(y>0)
          txa
          sta (lstore),y                ;lstore[y]=x
          add err,dy
          cmp dx                        ;if(err<dx)
          bcc .noshift                  ;{
          dex                           ;  y--
          sub err,dx                    ;  err-=dx
.noshift                                ;}
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
