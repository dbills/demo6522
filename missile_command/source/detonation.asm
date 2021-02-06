;;; missile detonations
.include "zerop.inc"
.include "detonation_graphics.inc"
.include "sprite.inc"
.include "m16.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.export queue_explosion, draw_explosions, i_detonation

spackle1 = %10101010
spackle2 = %01010101

.linecont
.data

explosion_frame_table:
.word        explosion_1_table \
            ,explosion_2_table \
            ,explosion_3_table \
            ,explosion_4_table \
            ,explosion_5_table \
            ,explosion_6_table \
            ,explosion_7_table \
            ,explosion_8_table \
            ,explosion_8_table \
            ,explosion_7_table \
            ,explosion_6_table \
            ,explosion_5_table \
            ,explosion_4_table \
            ,explosion_3_table \
            ,explosion_2_table \
            ,explosion_8_table
sz_explosion_frame_table = (* - explosion_frame_table)/2
explosion_yoffsets:     .byte  7,6,5,4,3,2,1,0,0,1,2,3,4,5,6,0
sz_explosion_yoffsets = * - explosion_yoffsets
.if ( sz_explosion_yoffsets <> sz_explosion_frame_table )
.error "explosion tables, check sizes"
.endif
.bss
slots = 30
i_explosion_frame:      .res 1
detonation_x:       .res slots
detonation_y:       .res slots
detonation_frame:   .res slots
.code

.export     test_explosion2
.proc       test_explosion2
            jsr i_detonation
            lda #0
            sta s_x
            sta s_y

            jsr queue_explosion

            lda #80
            sta s_x
            sta s_y
            jsr queue_explosion
loop:
            jsr draw_explosions
            jsr j_wfire
            jmp loop
            rts
.endproc
.proc       i_detonation
            ldx #slots-1
            lda #255
loop:
            sta detonation_frame,x
            dex
            bpl loop
            rts
.endproc
.include "shapes.mac"
.proc       queue_explosion
            ldx #slots-1
loop:
            lda detonation_frame,x
            bmi available
            dex
            bpl loop
            rts
available:
            lda _pl_x
            sec
            sbc #7
            sta detonation_x,x
            lda _pl_y
            sec
            sbc #7
            sta detonation_y,x
            lda #sz_explosion_frame_table
            sta detonation_frame,x
            rts
.endproc

.proc       draw_explosions
            lda s_x
            pha
            lda s_y
            pha
            ldx #slots-1
loop:
            lda detonation_frame,x
            bmi next
            jsr update_explosion
next:
            dex
            bpl loop
done:
            pla
            sta s_y
            pla
            sta s_x
            rts
.endproc

.proc       update_explosion
            lda detonation_frame,x
            bmi done
            cmp #sz_explosion_frame_table
            beq draw_first
            ;; erase
            jsr drawit2
            ;; update animation frame
draw_first:
            dec detonation_frame,x
            bmi done
            jsr drawit2
done:
            rts
.endproc

.proc       drawit2
            txa
            pha
            lda detonation_x,x
            sta s_x
            lda detonation_y,x
            clc
            ldy detonation_frame,x
            adc explosion_yoffsets,y
            sta s_y
            tya
            ;; multiple detonation_frame * 2
            asl
            tay
            lda explosion_frame_table,y
            sta ptr_0
            iny
            lda explosion_frame_table,y
            sta ptr_0+1

            lda #$ff
            sta spackle
            lda #0
            sta spacklator

            jsr draw_sprite16
            pla
            tax
            rts
.endproc
