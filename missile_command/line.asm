          org $1000
          processor 6502

DX        equ       0
DY        equ       1
X1        equ       2
X2        equ       3
Y1        equ       4
Y2        equ       5
ERR       equ       6
N         equ       7

LSTORE    equ       $2000

main
          lda #0
          sta X1
          sta Y1
          lda #160
          sta Y2
          lda #2
          sta X2
          
          jsr line1
          brk

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

          ldx DY                        ;for j=DX
.loop
          lda X1
          sta LSTORE,x
          lda ERR                       ;ERR+=DX
          clc
          adc DX
          sta ERR
          cmp N
          bcc .noshift                  ;move pixel
          inc X1
          lda #0
          sta ERR
.noshift
          ;; plot x,y : x=X1 y=x
          dex
          bne .loop
