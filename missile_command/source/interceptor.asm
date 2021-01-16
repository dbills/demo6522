;;; code for managing interceptor missiles
.include "screen.mac"
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "queue.mac"

.scope interceptor
.export in_initialize,in_launch,in_updateall

base_x = 176/2
base_y = 176-16

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
                         30, LINEMAX
.proc     in_updateall

          mov p_active,_lstore
          ldx active
loop:
          jsr _partial_render
          cpx next
          beq done
          inx
          add #LINEMAX,_lstore
          jmp loop
done:
          rts
.endproc

.proc     in_launch
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
          lineto #base_x,#base_y,_x2,_y2
          ldx next
          cpx #30
          beq empty
          jsr enqueue_interceptor
;          next_line p_next,next
empty:
          rts
.endproc

.endscope
