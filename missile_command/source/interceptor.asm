;;; code for managing interceptor missiles
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "queue.mac"
.include "sound.inc"
.include "sprite.inc"
.include "shapes.inc"
.include "system.mac"
.include "insertion_sort.inc"
.include "text.inc"
.include "debugscreen.inc"

.scope interceptor
.export in_initialize,launch,queue_iterate_interceptor,update_interceptors


base_x = XMAX/2
base_y = YMAX-16

.bss
p_next:   .word 0
;;; next, tail and p_tail are a queue of interceptors a player
;;; can launch - tail -> head in {0,29}
;;; p_tail,p_next pointer to  interceptor[tail] and interceptor[head]
;;; respectively
next:     .byte 0 
p_tail: .word 0
tail:   .byte 0
;;; last inserted

;;; indices of interceptors sorted by line length
;;; the missile nearest completion is always at tail
;;; this is true because
;;; all lengths decrease by the same amount on each frame
;;; and nothing end a interceptor except it reaching the end
;;; of its preset flight path
sorted_indices:     .res MAX_LINES
.code
.linecont
;;; lstore = iterator variable
;;; LINEMAX = size of a line struct ( the queue pointer math uses this )
;;; 0 = start index ( head )
;;; 1 = end index , therefore head E {0,1}
MAX_INTERCEPTOR=1
declare_queue_operations "interceptor", \
                         next, tail,\
                         p_next, p_tail,\
                         line_data01,0,\
                         MAX_INTERCEPTOR, LINEMAX,\
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

          ;; lda #0
          ;; sta s_x
          ;; lda #40
          ;; sta s_y
          rts
.endproc
;;; debug routine to allow the same
;;; interceptor to be fired over and over again
;;; while we work on collision detection which should be fun
.proc     reinitialize
          jsr queue_init_interceptor
          ldx #0
          lda #$ff
          sta sorted_indices,x
          rts
.endproc

.macro    show_sorted
          lda next
          sec
          sbc tail
          print_array sorted_indices, tail, next
          crlf
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
          cpx #MAX_MISSILES
          bne ok
          jmp empty
ok:
          lineto #base_x,#base_y,_x2,_y2
          ;lineto #base_x,#10,_x2,_y2
          ;; X has index of line just inserted
          insertion_sort sorted_indices,line_data_indices,tail,next,next
;          show_sorted
          jsr enqueue_interceptor
          jsr snd_missile_away
          rts
empty:
          snd_missile_empty
          rts
.endproc
.importzp _pl_x,_pl_y
.include "detonation.inc"
;;; erase crosshair centered at pl_x,pl_y
;;; sprites are drawn  from the upper left
;;; so we need to derive upper left coord
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
;          sp_draw crosshair, 5

          pla
          sta target_y
          pla
          sta target_x
          rts
.endproc

.bss
sort_index:         .res 1
.code
.macro    update_interceptors_ _tail,_head
          lda _tail
          sta sort_index
          ;; walk through the sorted array of interceptor
          ;; index values
loop:     
          ldy sort_index
          cpy _head
          beq done
          ;; load index of interceptor we are going to update
          ;; into x
          ldx sorted_indices,y
          ;; increment iterator in sorted array
          iny
          sty sort_index
          ;; set _lstore pointer to correct line
          lda queue_offsetsL_interceptor,x
          sta _lstore
          lda queue_offsetsH_interceptor,x
          sta _lstore+1
          jsr render_single_pixel
          beq erase
          ;; jsr render_single_pixel
          ;; beq erase
          ;; if Z on return the line is done
          bne active
erase:    
          ;; erase the line
          jsr _general_render
          jsr dequeue_interceptor
          ;; explosion
          jsr erase_crosshair_mark
          jsr queue_detonation
          ;; during debugging only
          jsr reinitialize
          jmp done
          ;; end debugging only
active:   
          jmp loop
done:     
.endmacro

.proc     update_interceptors
          update_interceptors_ tail,next
          rts
.endproc
.bss
i_line:   .res 1
.code
;;; called by the queue iterator function we declared
;;; IN:
;;;   X: line index
.proc update_interceptor
          rts
.endproc


.endscope
