.include "zerop.inc"
.include "shape_draw.inc"
.include "sprite.inc"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "playfield.inc"
.include "mushroom.mac"

.export mu_test, mu_init, mu_frame_num, mu_screen_col, mu_draw

.bss
mu_screen_col:         .res MU_MAX
mu_frame_num:          .res MU_MAX
.code

;;; Init mushroom cloud drawing
;;; IN:
;;; OUT:
.proc mu_init
          ldx #MU_MAX-1
          lda #MU_END_FRAME
loop:     
          sta mu_frame_num,x
          dex
          bpl loop
          rts
.endproc

;;; Draw mushroom cloud 
;;; those cities are sprite shift = 1
;;; IN:
;;;   Y: Y screen coord
;;;   X: frame of animation to draw
;;; OUT:
;;;
.proc mu_draw
          sy_dynajump mushroom_frames_shift0L, mushroom_frames_shift0H
.endproc

;;; ==========================================================================

.define test_city 6
.proc mu_test
start:    
          lda pl_city_x_positions + test_city
          sta _pl_x
          lda #test_city                ;city number
          mu_queue
loop:     
          waitv
          sc_update_frame
          mu_update 
          jmp loop
          rts
.endproc

