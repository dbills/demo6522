.include "bigletter.inc"
.include "scroller.inc"
.include "detonation.inc"
.include "screen.mac"
.include "zerop.inc"
.include "system.inc"
.include "detonation.inc"
.include "scroller.inc"

.export attract

.code

.proc attract
            jsr mcommand
            jsr i_scroller

loop:
            jsr rand_8
            and #7
            bne skip
            jsr rand_detonation
skip:
            waitv
            update_frame

            jsr erase_detonations
            jsr draw_detonations
            jsr scroll1
            ;; not time critical
            jsr update_detonations

            jmp loop
            rts
.endproc
