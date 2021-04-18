;;; code for managing interceptor missiles
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "queue.mac"
.include "sound.inc"
;.include "debugscreen.inc"
.include "text.inc"
.include "sprite.inc"
.include "shapes.inc"

.scope interceptor
.export in_initialize,launch,queue_iterate_interceptor

base_x = XMAX/2
base_y = YMAX-16

.bss
i_line:   .res 1                        ;tmpvar save current line index
p_next:   .word 0
next:     .byte 0
p_tail: .word 0
tail:   .byte 0
.code
.linecont
;;; lstore = iterator variable
declare_queue_operations "interceptor", \
                         next, tail,\
                         p_next, p_tail,\
                         line_data01,0,\
                         MAX_LINES, LINEMAX,\
                         _lstore, update_interceptor

.proc     in_initialize
          jsr queue_init_interceptor
          rts
.endproc

.proc     launch
          lda #crosshair_xoff
          clc
          adc target_x
          sta _x2
          lda #crosshair_yoff
          clc
          adc target_y
          sta _y2

          mov p_next,_lstore
          ldx next
          cpx #MAX_LINES
          beq fubar
          lineto #base_x,#base_y,_x2,_y2
          jsr enqueue_interceptor
          jsr missile_away
empty:
          rts
fubar:
          debug_number #$99
          rts
.endproc
.importzp _pl_x,_pl_y
.include "detonation.inc"

.proc     erase_crosshair_mark
          lda target_x
          pha
          lda target_y
          pha

          lda _pl_x
          sec
          sbc #crosshair_xoff
          sta target_x
          lda _pl_y
          sec
          sbc #crosshair_yoff
          sta target_y
          sp_draw crosshair, 5

          pla
          sta target_y
          pla
          sta target_x
          rts
.endproc

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
          debug_number tail
          jsr dequeue_interceptor
          ;; explosion
          stx i_line                    ;save x
          jsr erase_crosshair_mark
          jsr queue_detonation
          ldx i_line                    ;restore x
          rts
active:
          jmp render_single_pixel
.endproc

.proc     erase_line
.endproc
.endscope
