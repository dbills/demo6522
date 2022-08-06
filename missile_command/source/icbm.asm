;;; enemy icbm
;;; the sprite offsets for each city explosion can be derived
;;; from the assembled city constants, so there is one correct offset
;;; for each city

;;; this routine should select a city
;;; and generate a line for it

;;; we'll duplicate the existing line subsystem
;;; and say there are 10 missiles per wave ( or N )
;;; between waves we'll calculate a new wave and launch

;;; mirvs are preselected and in a table with the index of one
;;; of the existing lines
.include "line.inc"
.include "m16.mac"
.export icbm_genwave,icbm_update
.import  queue_offsetsL_interceptor, queue_offsetsH_interceptor
.data
;;; generate a delay to slow icbm advance
counter:  .byte 255
.code
;;; Draw one pixel for all enemy icbms active
;;; There is one array line line data for both icbm and player interceptors
;;; The first N are interceptors, the last N are icbms
;;; we start at beginning of second half to MAX_LINES
;;; 
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc     icbm_update
          ldx #MAX_MISSILES
loop:     
          cpx #MAX_LINES
          beq done
          ;; introduce delay {
          lda counter
          sec
          sbc #10
          sta counter
          bcs next
          adc #60
          sta counter
          ;; }
          ;; if the index = 0, then this line doesn't
          ;; need drawn
          lda line_data_indices,x
          beq next

          ;; set _lstore pointer to correct line
          ;; _lstore = &line_offsets[x]
          lda line_offsetsL,x
          sta _lstore
          lda line_offsetsH,x           
          sta _lstore+1
          ;; draw one pixel
          jsr render_single_pixel
next:   
          inx
          jmp loop
done:     
          rts
.endproc

;;; Creates the line definitions for 
;;; a attack wave
;;; todo: there are multiple waves per level
;;; so we need a function that captures that
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.import _general_render
.proc icbm_genwave
          mov #line_data01,_lstore
          ldx #1
          lineto #10,#10,#89,#155
          rts
          ldx #1
loop:     
          jsr render_single_pixel
          bne loop
loop2:    
          jmp loop2
          rts

.endproc

