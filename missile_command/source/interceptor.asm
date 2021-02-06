;;; code for managing interceptor missiles
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "queue.mac"
.include "sound.inc"
.include "debugscreen.inc"
.include "sprite.inc"

.scope interceptor
.export in_initialize,launch,updateall

base_x = 176/2
base_y = 176-16

.bss
i_line:   .res 1
.data
p_next:
          .word line_data01
next:
          .byte 0
p_active:
          .word line_data01
active:
          .byte 0
p_erased:
          .word line_data01
erased:
          .byte 0

.proc     in_initialize
          rts
.endproc
.linecont
declare_queue_operations "interceptor", \
                         next, active,\
                         p_next, p_active,\
                         line_data01,0,\
                         30, LINEMAX,\
                         _lstore, update_interceptor
.proc     updateall
          jsr queue_iterate_interceptor
          rts
.endproc

;; .proc     launch
;;           lda s_x
;;           sta _pl_x
;;           lda s_y
;;           sta _pl_y
;;           jsr queue_explosion
;;           rts
;; .endproc
.proc     launch
          rts
          lda #4
          clc
          adc s_x
          sta _x2
          lda #4
          clc
          adc s_y
          sta _y2

          mov p_next,_lstore
          ldx next
          cpx #29
          beq empty
          lineto #base_x,#base_y,_x2,_y2
          jsr enqueue_interceptor
          jsr missile_away
empty:
          rts
.endproc
.importzp _pl_x,_pl_y
.include "detonation.inc"
;;; called by the queue iterator function we declared
;;; IN:
;;;   X: line index
.proc update_interceptor
          ;; check if this interceptor is still active
          lda line_data_indices,x
          bne active
          ;; erase the line
          jsr _general_render
          ;; remove it
          jsr dequeue_interceptor
          ;; explosion
          stx i_line
          jsr queue_explosion
          ldx i_line
          rts
active:
          jmp render_single_pixel
.endproc

.proc     erase_line
.endproc
.endscope
