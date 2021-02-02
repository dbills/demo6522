;;; missile detonations
.include "zerop.inc"
.include "detonation_graphics.inc"
.include "sprite.inc"
.include "m16.mac"
.include "system.inc"
.include "jstick.inc"

.export test_explosion

spackle1 = %10101010
spackle2 = %01010101

.linecont
.data
explosion_frame_table:
.word explosion_1_shift0 \
     ,explosion_2_shift0 \
     ,explosion_3_shift0 \
     ,explosion_4_shift0 \
     ,explosion_5_shift0 \
     ,explosion_6_shift0 \
     ,explosion_7_shift0 \
     ,explosion_8_shift0 \
     ,explosion_8_shift0 \
     ,explosion_7_shift0 \
     ,explosion_6_shift0 \
     ,explosion_5_shift0 \
     ,explosion_4_shift0 \
     ,explosion_3_shift0 \
     ,explosion_2_shift0 \
     ,explosion_8_shift0
end_explosion_frame_table:
sz_explosion_frame_table = (end_explosion_frame_table - explosion_frame_table)/2
;explosion_yoffsets:     .byte 0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0
explosion_yoffsets:     .byte  7,6,5,4,3,2,1,0,0,1,2,3,4,5,6,0

.bss
slots = 30
i_explosion_frame:      .res 1
detonation_x:       .res slots
detonation_y:       .res slots
detonation_frame:   .res slots
.code

.export     test_explosion2
.proc       test_explosion2
            jsr detonation_init
            lda #0
            sta s_x
            sta s_y

            jsr queue_explosion
            ldx #slots-1
            jsr update_explosion
            jsr j_wfire
            rts
.endproc
.proc       detonation_init
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
            lda s_x
            sta detonation_x,x
            lda s_y
            sta detonation_y,x
            lda #sz_explosion_frame_table
            sta detonation_frame,x
            rts
.endproc

.proc       draw_explosions
            ldx #slots-1
loop:
            lda detonation_frame,x
            bmi next
            jsr update_explosion
next:
            dex
            bpl loop
done:
            rts
.endproc

.proc       update_explosion
            lda detonation_frame,x
            cmp #sz_explosion_frame_table
            beq never_drawn
            ;; erase existing
            jsr drawit2
            jmp draw
never_drawn:
            dec detonation_frame,x
draw:
            jsr drawit2
            dec detonation_frame,x
            rts
.endproc

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
            lda #$ff
            sta spackle
            lda #0
            sta spacklator
loop:
            jsr drawit
            dec i_explosion_frame
            bpl loop

            lda #0
            sta i_explosion_frame
loop2:
            lda #$ff
            sta spacklator

            lda #spackle1
            sta spackle
            jsr drawit

            lda #spackle2
            sta spackle
            jsr drawit

            lda #7
            cmp i_explosion_frame
            beq done
            inc i_explosion_frame
            jmp loop2
done:
            rts
.endproc
.proc       load_src
            lda i_explosion_frame
            asl
            tax
            lda explosion_frame_table,x
            sta ptr_0
            inx
            lda explosion_frame_table,x
            sta ptr_0+1
            rts
.endproc
.proc       drawit
            jsr load_src
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
            sleep 30

            jsr load_src
            jsr draw_sprite16
            rts
.endproc

.proc       drawit2
            lda detonation_frame,x
            asl
            tay
            lda explosion_frame_table,y
            sta ptr_0
            iny
            lda explosion_frame_table,y
            sta ptr_0+1

            lda detonation_x,x
            sta s_x
            ;; an offset is needed since the sprites don't include
            ;; blank lines
            lda detonation_y,x
            clc
            ;; y is detonation_frame
            ldy detonation_frame,x
            adc explosion_yoffsets,y
            sta s_y
            lda #$ff
            sta spackle
            lda #0
            sta spacklator

            jsr draw_sprite16
            rts
.endproc
