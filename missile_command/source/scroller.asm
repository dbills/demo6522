.include "zerop.inc"
.include "screen.mac"
.include "jstick.inc"
.include "colors.equ"
.include "text.inc"
.include "m16.mac"
.export scroller, i_scroller
.import wait_v
.importzp s_x,s_y
.bss
store:      .res 1
.data
defend:
.asciiz   "defend cities    press start"
.code

.proc       wait1
iloop:
          lda $9004
          cmp #70
          bne iloop
          rts
.endproc

.proc       i_scroller
            mov #defend,ptr_string
            lda #YMAX-8
            sta s_y
            lda #0
            sta s_x
            jsr _draw_string
.endproc

scroller:
            lda #0
            sta store
loop:
            bcolor_i CYAN
            rol store
            .repeat 8, PIXELROW
COL           .set SCRCOLS-1
              .repeat SCRCOLS
                rol CHBASE1 + (COL * SCRROWS * CHARHT) + PIXELROW + YMAX-8
COL             .set COL - 1
              .endrep
              rol store
            .endrep
            bcolor_i BLACK
            jsr wait1
            jmp loop
