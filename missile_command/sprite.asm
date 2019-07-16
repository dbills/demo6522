          SEG.U     ZEROP
sp_shape  dc.w
          SEG       CODE
;;; draw sprite at pl_x, pl_y
sp_draw   subroutine
          mov_w BORDA-1,ptr_2

          lda pl_x
          and #7
          clc
          adc #1
          asl                           ;(x%8+1)*16 to get
          asl                           ;preshifted
          asl                           ;image offset
          asl
          asl                           

          clc
          adc ptr_2
          sta BORDA-1
          lda #0
          adc ptr_2+1
          sta ptr_2+1

          lda pl_x
          ;; divide by 8
          ;; to get screen character column
          lsr
          lsr
          lsr
          ;; multiply by 2 to get zp address
          ;; of screen column CHRAM ptr
          ;; and place in Y
          asl
          tay
          ;; copy correct ptr to ptr_0
          lda pltbl,y                   ;
          sta ptr_0
          iny
          lda pltbl,y
          sta ptr_0 + 1
          ;; ptr_0 is location in CHRAM
          ;; of the correct character column
          iny
          lda pltbl,y
          sta ptr_1
          iny
          lda pltbl,y
          sta ptr_1 + 1
          ;; ptr_1 is right half of sprite
          ldy pl_y
          ldx #16
.loop1
N         equ 2
          lda (ptr_0),y
          eor [BORDA-1]+16*[8-N],X
          sta (ptr_0),y
          dex

          lda (ptr_1),y
          eor [BORDA-1]+16*[8-N],X
          sta (ptr_1),y

          iny
          dex
          bne .loop1
          rts

sp_move   subroutine
          rts
