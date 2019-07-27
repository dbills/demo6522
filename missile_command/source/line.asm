          ;; public line symbols
;          include "line.equ"
          ;; private line symbols
          SEG.U     ZEROP
err       dc.b
dx        dc.b
dy        dc.b
          SEG       CODE

line1     subroutine
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

          tay                           ;y=dy
          ldx x1                        ;x=x1
.loop                                   ;while(y>0)
          txa
          sta (lstore),y                ;lstore[y]=x
          add err,dx
          cmp dy                        ;if(err<dy)
          bcc .noshift                  ;{
          inx                           ;  x++
          sub err,dy                    ;  err-=dx
.noshift                                ;}
          ;; plot x,y : x=x1 y=x
          dey
          bne .loop                     ;
