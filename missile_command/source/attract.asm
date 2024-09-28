.include "bigletter.inc"
.include "detonation.inc"
.include "screen.mac"
.include "zerop.inc"
.include "system.inc"
.include "detonation.inc"
.include "colors.equ"
.include "jstick.inc"
.include "text.inc"

.export at_attract

.bss
trigger_count:      .res 1
store:              .res 1
.data
defend:
.asciiz   "game over    press start"
.code

;;; init the ticker tape scroller
.proc       init_scroller
            lda pltbl

            ldx #0
            mov #defend,ptr_string
            lda #YMAX-8
            sta s_y
            lda #0
            sta s_x
            jsr te_draw
            lda #0
            sta store
            rts
.endproc
;;; smooth scroll bottom 8 lines
scroll1:
            rol store
            .repeat 8, PIXELROW
COL           .set SCRCOLS-1
              .repeat SCRCOLS
                rol CHBASE1 + (COL * SCRROWS * CHARHT) + PIXELROW + YMAX-8
COL             .set COL - 1
              .endrep
              rol store
            .endrep
            rts
;;; the pre-game attract screen
.proc at_attract
          jsr bi_mcommand
          jsr init_scroller
          lda #0
          sta 36878
          sta trigger_count
loop:
          ;; check trigger position
          lda JOY0
          and #bJOYT
          bne trigger_up
trigger_down:       
          inc trigger_count
          jmp end_joy_read
trigger_up:
          lda trigger_count
          bne done
end_joy_read:       
          jsr rand_8
          and #15
          bne skip
          jsr de_rand
skip:
          waitv
          sc_bcolor CYAN
          sc_update_frame
          
          jsr de_erase
          jsr de_draw
          lda #1
          and frame_cnt
          bne noscroll
          jsr scroll1
noscroll:
          sc_bcolor PURPLE
          ;; not time critical
          jsr de_update_all
          
          jmp loop
done:     
          lda #8
          sta 36878
          rts
.endproc

