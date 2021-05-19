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
.export in_initialize,launch,queue_iterate_interceptor,unit_tests,fubar

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
          jmp empty
ok:
          lineto #base_x,#base_y,_x2,_y2
          ;; sorted array is 1 smaller until we insert
          dex
.bss
insert_point:       .res 1
.code
          sty insert_point
;          move_array sorted_indices, next, insert_point
          ;; insert
          lda next
          sta sorted_indices,y

          jsr enqueue_interceptor
          jsr missile_away
empty:
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

;;; sorted: array of sorted indices
;;; values: array of values
;;; end is 1 past end of array?
;;; we can never enter loop body with x = start
.macro    insertion_sort sorted, values, start, end, inserted
          .local done,loop
          ldx inserted
          lda values,x
          sta sort_key
          ldx end
          ;; walk backwards from end to start
          ;; while X > start
loop:     
          cpx start
          blte done
          ;; if line[x-1].length < line[insert].length
          ;;   break
          ldy sorted-1,x
          lda values,y
          cmp sort_key                ;line[x]-line[x-1]
          bcc done
          beq done
          ;; line[x]=line[x-1]
          lda sorted-1,x
          sta sorted,x
          dex
          jmp loop                      ;bpl? for bra
done:     
          ;; insert here, load index of inserted
          ;; and store in sorted
          lda inserted  
          sta sorted,x
.endmacro
;;; =============================================
;;; unit tests
;;; =============================================
;;; print direct array contents
.macro    direct_access array
          lda array,y
.endmacro
;;; print indirect array contents
.macro    indirect_access array,pointer
          ldx pointer,y
          lda array,x
.endmacro
.macro    print_array_ size,accessor
          .local loop
          ldy #0
loop:
          accessor
          sta scratch
          myprintf "%d,", scratch
          iny
          cpy #size
          bne loop
.endmacro
.macro    print_array array,size
          print_array_ size,{direct_access array}
.endmacro
.macro    print_indirect_array array,pointer,size
          print_array_ size,{indirect_access array, pointer}
.endmacro
.proc     unit_tests
insert_point = 1
.data
value_array:        .byte 7,1,5,4,3,2,6
test_array_sz = * - value_array
;;; set a test pattern in the sorted array starting at $A0
;;; so it's easy to spot parts that haven't been set yet
sorted_array:
.repeat test_array_sz,I
          .byte $A0 + I
.endrepeat
.bss
array_start:        .res 1
array_end:          .res 1
scratch:            .res 1
sort_key:           .res 1              ;last insert values
.code
          ;; initialize test data
          lda #0
          sta s_x
          sta s_y
          myprintf "abcdefghijklmnopqrstuvwxyz0123"
          lda #0
          sta array_start
          sta array_end

          insertion_sort sorted_array, value_array, array_start, array_end, array_end
          crlf
          print_indirect_array value_array, sorted_array,test_array_sz
          inc array_end
          insertion_sort sorted_array, value_array, array_start, array_end, array_end
          crlf
          print_indirect_array value_array, sorted_array,test_array_sz
          inc array_end
::fubar:
          insertion_sort sorted_array, value_array, array_start, array_end, array_end
          crlf
          print_indirect_array value_array, sorted_array,test_array_sz
          inc array_end
done:     
          rts
.endproc

.endscope


