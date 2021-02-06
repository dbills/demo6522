.include "math.mac"
.include "shapes.inc"
.include "zerop.inc"
.include "m16.mac"
.include "sprite.mac"
.export create_sprite_line,draw_sprite,draw_unshifted_sprite,left_byte,right_byte,shift,height,draw_sprite16,spacklator,spackle
.exportzp s_x,s_y,target_x,target_y
.zeropage
s_x:        .res 1
s_y:        .res 1
target_x:   .res 1
target_y:   .res 1
.data
left_byte:  .byte 0
right_byte: .byte 0
shift:      .byte 0
height:     .byte 0
scratch:    .byte 0
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
.macro      calculate_adjusted_sprite_source
.endmacro
            ;; preshifted sprite drawing
            ;; s_x: X coordinate
            ;; s_y: Y coordinate
            ;; input:
            ;;   ptr_0: point to sprite source data
            ;; output:
            ;;   ptr_0 pointer to CHRAM column left tile
            ;;   ptr_1 pointer to CHRAM column right tile
            ;;   ptr_2 adjusted pointer to sprite source
            ;;         s.t. ptr_2 + s_y = sprite_source data
.macro      calculate_hires_pointers _x,_y
            sub_wbw ptr_0,_y,ptr_2
            lda _x
            calc_screen_column
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
.endmacro
.import screen_column
.macro      opto_calculate_hires_pointers _x,_y,p_column3
            sub_wbw ptr_0,_y,ptr_2
            ldy screen_column,x
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
            iny
            lda pltbl,y
            sta p_column3
            iny
            lda pltbl,y
            sta p_column3+1
.endmacro
;;; draw sprite at s_x,x s_y,x
;;; we need 4 pointers? screen column A,B ( left and right side of 16 bit sprite )
;;; sprite source data ( left and right side ) ptr0,1,2,3
;;; A = height of sprite
.proc     draw_sprite
          pha
          calculate_hires_pointers target_x,target_y

          modulo8 target_x                   ;find correct bit offset
          mul16                         ;in preshifted images
          clc
          adc ptr_2
          sta ptr_2
          lda #0
          adc ptr_2+1
          sta ptr_2+1
          add_wbw ptr_2,#8,ptr_3
          ;; ptr_3 contains pointer to preshifted tiles

          ldy target_y
          pla
          tax
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
;;; draw a sprite that does not have
;;; preshifted images
.proc       draw_unshifted_sprite
            calculate_hires_pointers s_x,s_y
            ;; ptr_0, ptr_1 hires column  pointers
            ;; ptr_2 adjusted source bytes
            ldy s_y
            ;; calculate loop end in scratch
            tya
            clc
            ;; letters are only 7 tall
            ;adc #7
            adc height
            sta scratch
loop:
            modulo8 s_x
            sta shift
            lda (ptr_2),y
        	jsr create_sprite_line
            lda left_byte
            eor (ptr_0),y
            sta (ptr_0),y
            lda right_byte
            eor (ptr_1),y
            sta (ptr_1),y
            iny
            cpy scratch
            bne loop
            rts
.endproc
.bss
sprite_height: .res 1
spackle:    .res 1
spacklator: .res 1
.code
.macro      add_sprite_height src,dst
            lda src
            clc
            adc sprite_height
            sta dst
            lda src+1
            adc #0
            sta dst+1
.endmacro
;;; in: ptr,s_x
;;; out: ptr
.macro      read_shift_table ptr
            modulo8 s_x
            asl
            tay
            lda (ptr),y
            pha
            iny
            lda (ptr),y
            sta ptr+1
            pla
            sta ptr
.endmacro
;;; 16 pixel wide, variable height
;;; sprites, preshifted
;;; in: ptr_0 - pointer to preshifted sprite
.proc       draw_sprite16
sp_src0 = smc0 + 1
sp_src1 = smc1 + 1
sp_src2 = smc2 + 1
            read_shift_table ptr_0
            ;; calculate screen column pointer
            ;; and adjusted sprite source data base pointer
            ;; ptr_0 must point to pre shifted sprite image
            ldy #0
            lda (ptr_0),y
            sta sprite_height
            incw ptr_0
            opto_calculate_hires_pointers s_x,s_y,sp_col2
            ;; setup three strips of bytes to copy to screen
            mov ptr_2,sp_src0
            add_sprite_height sp_src0, sp_src1
            add_sprite_height sp_src1, sp_src2

            ldy s_y
            ldx sprite_height           ;loop counter
loop:
            lda (sp_col0),y
smc0:
            eor 0,y
            sta (sp_col0),y

            lda (sp_col1),y
smc1:
            eor 0,y
            sta (sp_col1),y

            lda (sp_col2),y
smc2:
            eor 0,y
            sta (sp_col2),y

            iny
            dex
            bne loop

            rts
.endproc
