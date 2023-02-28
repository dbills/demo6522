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
.include "detonation.inc"
.include "m16.mac"
.include "screen.inc"
.include "zerop.inc"
.include "system.inc"
.include "playfield.inc"

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
          sbc #5
          sta counter
          bcs next
          adc #60
          sta counter
          ;; }
          ;; if the index = 0, then this line doesn't
          ;; need drawn
          lda line_data_indices,x
          beq next
          li_setz_lstore
          jsr li_render_pixel
          beq reached_target
          de_collision _pl_x, _pl_y
          lda de_hit
          beq next
          ;; icbm was destroy by a detonation
          ;; save it's current location - we erase to this point in scratch1
          lda line_data_indices,x
          sta scratch1               
          li_reset_line               
          ;; erase it, up to where it as
erase_loop:
          jsr li_render_pixel
          lda line_data_indices,x
          cmp scratch1
          bne erase_loop
          ;; deactivate line
          lda #0
          sta line_data_indices,x
          ;; queue another detonation, pl_x,pl_y already set
          savex
          jsr de_queue
          resx
next:   
          inx
          jmp loop
done:     
          rts
          ;; a city will be destroyed
          ;; jsr pl_mushroom
reached_target:     
          li_deactivate
.endproc

.zeropage
sy_rand:  .res 1
.code
.proc rand_n
          jsr rand_8
          ;; A % N
loop:     
          sec
          sbc #sy_rand
          cmp sy_rand
          blte loop
          rts
.endproc

.proc random_city
          savey
          lda #6
          sta sy_rand
          jsr rand_n 
          tay
          lda pl_city_x_positions,y
          clc
          adc #6                        ;city width / 2 
          sta z_x2
          lda #155
          sta z_y2
          resy
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
.import li_full_render
.proc icbm_genwave
          mov #line_data01,z_lstore
          ldx #1
          li_lineto #10,#10,#89,#155
          rts
          ldx #1
loop:     
          jsr li_render_pixel
          bne loop
loop2:    
          jmp loop2
          rts

.endproc

