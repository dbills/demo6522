.include "math.mac"
.include "shapes.inc"
.include "zerop.inc"
.include "m16.mac"
.include "detonation_graphics.inc"
.export calculate_hires_pointers,create_sprite_line,draw_sprite,draw_unshifted_sprite
.export left_byte,right_byte,shift,height
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
            ;; pointer from table, i.e. shift right
            ;; twice and clear low bit
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
.macro      calculate_hires_pointers16 _1
            jsr calculate_hires_pointers
            ;; put a third CHRAM pointer in _1
            iny
            lda pltbl,y
            sta _1
            iny
            lda pltbl,y
            sta _1+1
.endmacro
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
;;; draw a sprite that does not have
;;; preshifted images
.proc       draw_unshifted_sprite
            jsr calculate_hires_pointers
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
;;; 16 pixel wide, variable height
;;; sprites, preshifted
;;; in:
.proc       draw_sprite16
sp_src0 = smc0 + 1
sp_src1 = smc1 + 1
sp_src2 = smc2 + 1
            ;; calculate screen column pointer
            ;; and adjusted sprite source data base pointer
            ldy #0
            lda (ptr_0),y
            sta sprite_height
            incw ptr_0
            calculate_hires_pointers16 sp_col2
            ;; setup three strips of bytes to copy to screen
            mov ptr_2,sp_src0
            add_sprite_height sp_src0, sp_src1
            add_sprite_height sp_src1, sp_src2

            ldy s_y
            ldx sprite_height           ;loop counter
loop:
smc0:
            lda 0,y
            sta (sp_col0),y
smc1:
            lda 0,y
            sta (sp_col1),y
smc2:
            lda 0,y
            sta (sp_col2),y
            iny
            dex
            bne loop
            rts
.endproc
.linecont
explosion_frame_table:
.word explosion_8_shift0 \
     ,explosion_7_shift0 \
     ,explosion_6_shift0 \
     ,explosion_5_shift0 \
     ,explosion_4_shift0 \
     ,explosion_3_shift0 \
     ,explosion_2_shift0 \
     ,explosion_1_shift0

.bss
i_explosion_frame:      .res 1
.code
.include "system.inc"
.include "jstick.inc"
.export     test_explosion
.proc       ztest_explosion
            mov #explosion_1_shift0, ptr_0

            lda #0
            sta s_x
            lda #1
            sta s_y
            jsr draw_sprite16
            rts
.endproc
.proc       test_explosion
                                        ;explosion_8_shift0:
                                        ;explosion_8_shift0_strip0:
            lda #7
            sta i_explosion_frame
loop:
            waitv

            lda i_explosion_frame
            asl
            tax
            lda explosion_frame_table,x
            sta ptr_0
            inx
            lda explosion_frame_table,x
            sta ptr_0+1
            ;mov #explosion_8_shift0, ptr_0

            lda #0
            sta s_x
            sta s_y
            ;; an offset is needed since the sprites don't include
            ;; blank lines
            lda s_y
            clc
            adc i_explosion_frame
            sta s_y

            jsr draw_sprite16

            jsr j_wfire
;            jsr draw_sprite16

            dec i_explosion_frame
            bpl loop
            rts
.endproc
