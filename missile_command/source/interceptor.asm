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
.export in_initialize,launch,queue_iterate_interceptor,unit_tests



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

;;; find first greater ( insert point ) in inteceptor array. first part
;;; of an insertion sort
;;; out: Y = insert point
.macro    find_insert_point
          .local loop, done
          ;; sort
          ;; X = index of line just inserted
          ;; A = length of new line
          lda line_data_indices,x
          debug_number A
          ldy tail                      ;start at beginning
loop:
          cpy next                      ;did we reach end
          beq done
          ldx sorted_indices,y          ;load index of item to compare
          cmp line_data_indices,x       ;compare remaining length
          bcc done                      ;this line is longer than us
          iny                           ;increment loop counter
          jmp loop
done:
.endmacro

;;; move array down from (start,end]
;;; leaving a hole at start
.macro    move_array array,start,end
          .local move_loop,done
          ldy end
move_loop:
          cpy start
          beq done
          lda array-1,y
          sta array,y
          dey
          bpl move_loop                 ;branch always
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
          find_insert_point             ;insert point in Y
.bss
insert_point:      .res 1
.code
          ;; Y is index in sorted to insert at
          sty insert_point
          ldy next
          dey
          move_array sorted_indices,next,insert_point
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
;;; =============================================
;;; unit tests
;;; =============================================
.proc     unit_tests
insert_point = 6
.data
test_array:         .byte 1,2,3,5,6,7,0
.bss
scratch:  .res 1
.code
          ;; initialize test data
          lda #0
          sta s_x
          sta s_y
          myprintf "unit test"
          add8 #8,s_y
          move_array test_array, #insert_point, #6
          lda #4
          sta test_array+insert_point
          lda #0
          sta s_x
          myprintf "sorted:"
          ldy #0
loop:
          lda test_array,y
          sta scratch
          myprintf "%d,", scratch
          iny
          cpy #7
          bne loop
          rts
.endproc
.endscope
