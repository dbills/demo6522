;;; code for managing interceptor missiles
.include "screen.mac"
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"

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
          .word 0
active:
          .byte 0
p_erased:
          .word line_data01
erased:
          .byte 0

.proc     in_initialize
          rts
.endproc

.proc     in_updateall

          LINE_NUMBER .set 0
.repeat MAX_LINES
          LINE_NUMBER .set LINE_NUMBER + 1
          mov #.ident (.sprintf ("line_data%02d", LINE_NUMBER)),_lstore
          ldx #LINE_NUMBER-1
          jsr _partial_render
.endrepeat

;; loop:
;;           mov p_active,_lstore
;;           ldx  active

;;           jsr _partial_render

;;           lda active
;;           cmp next
;;           beq done
;;           next_line p_active,active
;;           jmp loop
;; done:
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
          next_line p_next,next
empty:
          rts
.endproc

.endscope
