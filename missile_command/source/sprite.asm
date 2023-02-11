.include "math.mac"
.include "shapes.inc"
.include "zerop.inc"
.include "m16.mac"
.include "sprite.mac"
.export sp_draw_unshifted, shift, sp_height,spacklator,spackle
.exportzp s_x,s_y,target_x,target_y
.zeropage
s_x:        .res 1
s_y:        .res 1
target_x:   .res 1
target_y:   .res 1
.bss
;;; could these be bss?
.data
left_byte:  .byte 0
right_byte: .byte 0
shift:      .byte 0
sp_height:  .byte 0
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
;;; draw a sprite that does not have
;;; preshifted images
.proc       sp_draw_unshifted
            calculate_hires_pointers s_x,s_y
            ;; ptr_0, ptr_1 hires column  pointers
            ;; ptr_2 adjusted source bytes
            ldy s_y
            ;; calculate loop end in scratch
            tya
            clc
            adc sp_height
            sta scratch
loop:
            modulo8 s_x
            sta shift
            lda (ptr_2),y
            jsr create_sprite_line
            lda (ptr_0),y
            eor left_byte
            sta (ptr_0),y
            lda (ptr_1),y
            eor right_byte
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
