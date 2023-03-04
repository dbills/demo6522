.include "zerop.inc"
.include "mushroom_draw.inc"
.include "sprite.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "playfield.inc"
.include "mushroom.mac"

.export mu_test, mu_init, mu_frame_num, mu_screen_col, mu_draw_east, mu_draw_west

.bss
mu_screen_col:         .res MU_MAX
mu_frame_num:          .res MU_MAX
.zeropage
mushroom_idx:       .res 1
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

;;; Draw mushroom cloud for wester cities ( left side of bse )
;;; those cities are sprite shift = 1
;;; IN:
;;;   Y: Y screen coord
;;;   X: frame of animation to draw
;;; OUT:
;;;
.proc mu_draw_west 
          sy_dynajump mushroom_frames_shift1L,mushroom_frames_shift1H
.endproc

;;; draw mushroom cloud for wester cities ( right side of base )
;;; IN:
;;;   Y: Y screen coord
;;;   X: frame of animation to draw
;;; OUT:
;;;
.proc mu_draw_east
          sy_dynajump mushroom_frames_shift5L,mushroom_frames_shift5H
.endproc

;;; ==========================================================================

.proc mu_test
start:    
          lda #17
          sta _pl_x
          lda #0   
          mu_queue
loop:     
          mu_update 0
          beq start

          ldy #240
waiter:   
          waitv
          dey
          bne waiter
          
          jmp loop
          rts
.endproc

