;;; missile detonations
.include "zerop.inc"
.include "detonation_graphics.inc"
.include "sprite.inc"
.include "m16.mac"
.export test_explosion

spackle1 = %10101010
spackle2 = %01010101

.linecont
.data
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
