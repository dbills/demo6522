          ;; public line symbols
;          include "line.equ"
          ;; private line symbols
          SEG.U     ZEROP
err       dc.b
dx        dc.b
dy        dc.b
          SEG       CODE

line1     subroutine
          ;; initialize error counter
          ;; and delta Y, delta X
          ;; 
          lda #0
          sta err
          lda x2
          sec
          sbc x1
          sta dx
          lda y2
          sec
          sbc y1
          sta dy
          ldy dy                     
.loop                                   ;while(y>0)
          lda x1
          sta (lstore),y
          add err,dx
          cmp dy                        ;if(err<dy)
          bcc .noshift                  ;{
          inc x1                        ;  x++
          sub err,dy                    ;  err-=dx
.noshift                                ;}
          ;; plot x,y : x=x1 y=x
          dey
          bne .loop                     ;
;;; hmm, we should try counting up?
;;; let X is the indirect addressing register 
;;; sneaky eh, so we'd start at X+255 = address + DY
;;; address - 255 + DY = X
;;; but that requires runtime calculation, so that sucks
