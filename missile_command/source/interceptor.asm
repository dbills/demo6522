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
i_line:   .res 1                        ;tmpvar save current line index
p_next:   .word 0
;;; location of next free line/interceptor slot
next:     .byte 0 
p_tail: .word 0
tail:   .byte 0
;;; last inserted
;inserted .byte 0
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

          lda #0
          sta s_x
          lda #40
          sta s_y
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
          ;; X has index of line just inserted
          insertion_sort sorted_indices,line_data_indices,tail,next,next
          jsr enqueue_interceptor
          jsr snd_missile_away

          print_array sorted_indices, #0, #2
          crlf
          rts
empty:
          snd_missile_empty
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

.proc     update_interceptors
.bss
sort_index:         .res 1
.code
          lda tail
          sta sort_index
          ;; walk through the sorted array of interceptor
          ;; index values
loop:     
          ldy sort_index
          cpy next
          beq done
          ;; load index of interceptor we are going to update
          ;; into x
          ldx sorted_indices,y
          ;; increment iterator in sorted array
          iny
          sty sort_index

          lda queue_offsetsL_interceptor,x
          sta _lstore
          lda queue_offsetsH_interceptor,x
          sta _lstore+1
          jsr render_single_pixel
          ;; if Z on return the line is done
          bne active
          ;; erase the line
          jsr _general_render
          jsr dequeue_interceptor
          ;; explosion
          jsr erase_crosshair_mark
          jsr queue_detonation
active:   
          jmp loop
done:     
          rts
.endproc

.endscope
