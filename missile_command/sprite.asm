          include "comp.mac"

          SEG.U     ZEROP
sp_shape  dc.w
          SEG       CODE
;;; draw sprite at pl_x, pl_y
;;; we need 4 pointers? screen column A,B ( left and right side of 16 bit sprite )
;;; sprite source data ( left and right side ) ptr0,1,2,3
;;; 
sp_draw   subroutine
N         equ 1
          sub_abw BORDA,pl_y,ptr_2
          modulo8 pl_x
          mul16
          clc
          adc ptr_2
          sta ptr_2
          lda #0
          adc ptr_2+1
          sta ptr_2+1
          add_wbw ptr_2,#8,ptr_3

          ;; divide by 8
          ;; to get screen character column
          lda pl_x
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
          ldx #8
.loop1
          lda (ptr_1),y
          eor (ptr_3),y
          sta (ptr_1),y

          lda (ptr_0),y
          eor (ptr_2),y       
          sta (ptr_0),y

          iny
          dex
          bne .loop1
          rts

sp_move   subroutine
          rts

          MAC abort
          lda #$c0
          sta 9005
          brk
          ENDM

;; cbounds   subroutine          
;;           lda #175
;;           cmp pl_x            
;;           bcc .ob
;;           lda pl_y
;;           rts
;; .ob
;;           lda #0
;;           sta pl_x
;;           rts
