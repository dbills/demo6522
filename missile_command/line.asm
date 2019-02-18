          ;; public line symbols
;          include "line.equ"
          ;; private line symbols
          SEG.U     ZEROP
err       dc.b
n         dc.b
dx        dc.b
dy        dc.b
          SEG       CODE

main
          lda #0
          sta x1
          sta y1
          lda #160
          sta y2
          lda #2
          sta x2
          
          jsr line1
          brk

line1     subroutine
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
          lsr
          sta n

          ldx dy                        ;for j=dx
.loop
          lda x1
          sta lstore,x
          lda err                       ;err+=dx
          clc
          adc dx
          sta err
          cmp n
          bcc .noshift                  ;move pixel
          inc x1
          lda #0
          sta err
.noshift
          ;; plot x,y : x=x1 y=x
          dex
          bne .loop
