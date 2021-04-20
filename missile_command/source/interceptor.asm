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
;;; indices of interceptors sorted by line length
;;; the missile nearest completion is always at tail
;;; all missile lengths decreases on each frame
sorted_indices:     .res MAX_LINES
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
          ldx #MAX_LINES-1
          lda #$ff
          ;; clear sorted_indices
loop:
          sta sorted_indices,x
          dex
          bpl loop

          rts
.endproc

;;; perform an insertion sort on the interceptors
.macro    first_greater array, i_start, i_end
          .local loop,done
          ldy i_start
          ldy i_start
loop:
          cpy i_end
          beq done
          ldx array,y
          compare
          bcc done
          bcs loop
done:
.endmacro

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
          bne ok
          jmp fubar
ok:
          lineto #base_x,#base_y,_x2,_y2
          jsr enqueue_interceptor
          debug_number X
          jsr missile_away
          ;; sort
          ;; X = index of line just inserted
          ;; A = length of new line
          lda line_data_indices,x
          debug_number A
          ldy tail
loop:
          cpy next
          beq insert_here
          ldx sorted_indices,y
;          bmi insert_here
          ;; compare current line length
          cmp line_data_indices,x
          ;; this line is longer than us, we should
          ;; insert here
          bcc insert_here
          iny
          jmp loop
insert_here:
.bss
insert_point:      .res 1
.code
          ;; Y is index in sorted to insert at
          debug_number #$AA
          debug_number Y
          sty insert_point
          ldy next
          dey
move_loop:                              ;while q.items
          cpy tail
          beq insert
          cpy insert_point
          beq insert
          lda sorted_indices-1,y
          sta sorted_indices,y
          dey
          jmp move_loop
insert:
          lda next
          sec
          sbc #1
          sta sorted_indices,y
empty:
          debug_number sorted_indices
          debug_number sorted_indices+1
          debug_number #$EE
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
          ;debug_number tail
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
