          include "comp.mac"
          
;;; draw sprite at s_x,x s_y,x
;;; we need 4 pointers? screen column A,B ( left and right side of 16 bit sprite )
;;; sprite source data ( left and right side ) ptr0,1,2,3
;;; 
sp_draw   subroutine
          ;sub_abw BORDA,s_y,ptr_2
          sub_abw LETA,s_y,ptr_2

          modulo8 s_x,x                 ;find correct bit offset
          mul16                         ;in preshifted images
          
          sec
          sbc s_y
          ;; if carry is clear i have a negative number
          
          clc
          adc ptr_2
          sta ptr_2
          lda #0
          adc ptr_2+1
          sta ptr_2+1
          add_wbw ptr_2,#8,ptr_3

          ;; divide by 8
          ;; to get screen character column
          lda s_x,x
          lsr
          lsr
          and #$fe
          tay
          ;; copy correct ptr to ptr_0
          lda pltbl,y                   ;
          sta ptr_0
          lda pltbl+1,y
          sta ptr_0 + 1
          ;; ptr_0 is location in CHRAM
          ;; of the correct character column
          lda pltbl+2,y
          sta ptr_1
          lda pltbl+3,y
          sta ptr_1 + 1
          ;; ptr_1 is right half of sprite

          ldy s_y,x
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

          MAC abort
          lda #$c0
          sta 9005
          brk
          ENDM

          ;; X = Y offset
          ;; ptr_0 sprite to draw
                    mac hard_draw_sprite
BYTE_OFFSET         set 0
                    repeat 8
                    lda {1} + BYTE_OFFSET
                    sta {2} + BYTE_OFFSET,y
BYTE_OFFSET         set BYTE_OFFSET + 1
                    repend
                    repeat 8
                    lda {1} + BYTE_OFFSET
                    sta {2} + BYTE_OFFSET,y
                    repend
                    endm
          
fast_draw_sprite    subroutine
                    hard_draw_sprite BORDA,SCADDR
                    rts
