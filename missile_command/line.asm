          org 1000
          processor 6502

DX        equ       0
DY        equ       1
X1        equ       2
X2        equ       3
Y1        equ       4
Y2        equ       5
ERR       equ       6
N         equ       7
line1     subroutine
          lda #0
          sta ERR
          lda X2
          sec
          sbc X1
          sta DX
          lda Y2
          sec
          sbc Y1
          sta DY
          lsr
          sta N

          ldx DX                        ;for j=DX
.loop
          lda ERR                       ;ERR+=DX
          clc
          adc DX
          cmp N
          bcs .noshift                    ; move pixel
          inc X1
.noshift
          ;; plot x,y : x=X1 y=x
          dex
          bne .loop





