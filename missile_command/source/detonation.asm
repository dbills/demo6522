;;; missile detonations
.include "zerop.inc"
.include "detonation_graphics.inc"
.include "sprite.inc"
.include "m16.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "shapes.mac"
.export queue_explosion, draw_explosions, i_detonation, speed_test

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
frame_delay = 20
i_explosion_frame:      .res 1
detonation_x:       .res slots
detonation_y:       .res slots
detonation_frame:   .res slots
.export screen_column
screen_column:      .res slots
.code

.proc speed_test
            lda #16
            sta _pl_y
            lda #16
            sta _pl_x
            ldy #10
loop:
            jsr queue_explosion
            lda _pl_x
            clc
            adc #6
            sta _pl_x

            lda _pl_y
            clc
            adc #6
            sta _pl_y

            dey
            bpl loop
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
            sbc #detonation_xoff
            sta detonation_x,x
            calc_screen_column
            sta screen_column,x
            lda _pl_y
            sec
            sbc #detonation_yoff
            sta detonation_y,x
            lda #sz_explosion_frame_table
            sta detonation_frame,x
            rts
.endproc

.macro      update_explosion
            .local draw_first,done,reset
            lda detonation_frame,x
            bmi end
            cmp #sz_explosion_frame_table
            beq draw_first
            ;; erase
            jsr drawit2
            ;; update animation frame
draw_first:
            dec detonation_frame,x
;            bmi done
            bmi reset
            jsr drawit2
            jmp end
reset:
            lda #sz_explosion_frame_table
            sta detonation_frame,x
end:
.endmacro

.proc       draw_explosions
            ldx #slots-1
loop:
            txa
            ;; draw when frame_cnt match X index
            eor frame_cnt
            bne next
            update_explosion
next:
            dex
            bpl loop
done:
            rts
.endproc

.zeropage
drawit_savex:           .res 1
.code
.proc       drawit2
            stx drawit_savex
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

            jsr draw_sprite16
            ldx drawit_savex
            rts
.endproc
