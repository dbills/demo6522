.include "zerop.inc"
.include "mushroom_draw.inc"
.include "sprite.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "playfield.inc"
.include "mushroom.mac"

.export mu_test, mu_init, mu_frame_num, mu_screen_col, mu_draw

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

;;; draw mushroom cloud
;;; IN:
;;;   Y: Y screen coord
;;;   X: frame of animation to draw
;;; OUT:
;;;
.proc mu_draw
          sy_dynajump mushroom_framesL,mushroom_framesH
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

