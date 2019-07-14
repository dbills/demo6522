          SEG.U     ZEROP
sp_shape  dc.w
          SEG       CODE
;;; draw sprite at pl_x, pl_y
sp_draw   subroutine
          ;; grab X % 8 for
          ;; bit offset in byte
          lda #%00000111
          and pl_x
          tay
          ldx BMASKS,y          ;y=bitmask
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
          ldy #0
          ldx #16
.loop1
          lda BORDA-1,X
          sta (ptr_0),y
          dex
          lda BORDA-1,X
          sta (ptr_1),y
          dex
          bne .loop1
          rts

sp_move   subroutine
          rts
