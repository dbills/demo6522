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
.proc     icbm_update
          ldx #MAX_MISSILES
loop:     
          cpx #MAX_LINES
          beq done

          lda counter
          sec
          sbc #10
          sta counter
          bcs next
          adc #60
          sta counter
          
          ldx #1
          ;; if the index = 0, then this line doens't
          ;; need drawn
          lda line_data_indices,x
          beq next

          ;; set _lstore pointer to correct line
          lda queue_offsetsL_interceptor,x
          sta _lstore
          lda queue_offsetsH_interceptor,x
          sta _lstore+1
          ;; draw one pixel
          ;mov #line_data01,_lstore
          jsr render_single_pixel
next:   
          inx
          jmp loop
done:     
          rts
.endproc

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

