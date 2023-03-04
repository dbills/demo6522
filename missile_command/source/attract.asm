.include "bigletter.inc"
.include "scroller.inc"
.include "detonation.inc"
.include "screen.mac"
.include "zerop.inc"
.include "system.inc"
.include "detonation.inc"
.include "scroller.inc"
.include "colors.equ"
.include "playfield.inc"

.export attract

.code

.proc attract
            jsr mcommand
            jsr i_scroller
            jsr pl_draw_cities

loop:
            jsr rand_8
            and #15
            bne skip
            jsr de_rand
skip:
            waitv
            bcolor_i CYAN
            sc_update_frame

            jsr de_erase
            jsr de_draw
            lda #1
            and frame_cnt
            bne noscroll
            jsr scroll1
noscroll:
            bcolor_i PURPLE
            ;; not time critical
            jsr de_update

            jmp loop
            rts
.endproc
