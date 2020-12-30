.include "math.mac"
.include "shapes.inc"
.include "zerop.inc"
.include "m16.mac"
.export calculate_hires_pointers,create_sprite_line,draw_sprite
.export left_byte,right_byte,shift
.import LETA
.data
left_byte:  .byte 0
right_byte: .byte 0
shift:      .byte 0
.code
            ;; IN: shift - amount to shift to right
            ;;     A - source byte
            ;; OUT:
            ;;   left_byte
            ;;   right_byte
.proc       create_sprite_line
            sta left_byte
            lda #0
            sta right_byte
            ldx shift
            beq done
loop:       
            lsr left_byte
            ror right_byte
            dex
            bne loop
done:       
            rts
.endproc
            ;; preshifted sprite drawing
            ;; s_x: X coordinate
            ;; s_y: Y coordinate
            ;; input:
            ;;   ptr_0: point to sprite source data
            ;; output: 
            ;;   ptr_0 pointer to CHRAM column left tile
            ;;   ptr_1 pointer to CHRAM column right tile
            ;;   ptr_2 adjusted pointer to sprite source
            ;;         s.t. ptr+2 + s_y = sprite_source data
.proc       calculate_hires_pointers
            lda ptr_0
            sec
            sbc s_y
            sta ptr_2
            lda ptr_0+1
            sbc #0
            sta ptr_2+1
            ;; divide by 8, multiply by 2
            ;; to get screen character column
            ;; pointer from table 
            lda s_x
            lsr
            lsr
            and #$fe
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
            rts
.endproc    
;;; draw sprite at s_x,x s_y,x
;;; we need 4 pointers? screen column A,B ( left and right side of 16 bit sprite )
;;; sprite source data ( left and right side ) ptr0,1,2,3
;;; 
.proc     draw_sprite
          jsr calculate_hires_pointers

          modulo8 s_x                   ;find correct bit offset
          mul16                         ;in preshifted images
          clc
          adc ptr_2
          sta ptr_2
          lda #0
          adc ptr_2+1
          sta ptr_2+1
          add_wbw ptr_2,#8,ptr_3
          ;; ptr_3 contains pointer to preshifted tiles

          ldy s_y
          ldx #8
loop1:      
          lda (ptr_1),y
          eor (ptr_3),y
          sta (ptr_1),y

          lda (ptr_0),y
          eor (ptr_2),y       
          sta (ptr_0),y

          iny
          dex
          bne loop1
          rts
.endproc
