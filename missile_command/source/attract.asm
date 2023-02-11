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
            lda #YMAX-16
            sta city_base
            jsr draw_cities

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
            jsr de_draw
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
