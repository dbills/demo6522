.include "bigletter.inc"
.include "scroller.inc"
.include "detonation.inc"
.include "screen.mac"
.include "zerop.inc"
.include "system.inc"
.include "detonation.inc"
.include "scroller.inc"
.include "colors.equ"

.export attract

.code

.proc attract
            jsr mcommand
            jsr i_scroller

loop:
            jsr rand_8
            and #15
            bne skip
            jsr rand_detonation
skip:
            waitv
            bcolor_i CYAN
            update_frame

            jsr erase_detonations
            jsr draw_detonations
            lda #1
            and frame_cnt
            bne noscroll
            jsr scroll1
noscroll:
            bcolor_i PURPLE
            ;; not time critical
            jsr update_detonations

            jmp loop
            rts
.endproc
