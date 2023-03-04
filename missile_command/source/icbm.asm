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
.include "mushroom.inc"

.export icbm_genwave,icbm_update
.import  queue_offsetsL_interceptor, queue_offsetsH_interceptor

;;; height above a city that icbm targets
detonation_height = 5
;;; distance from left of city to it's centerline where icbms target
city_centerline = 9
.data
;;; generate a delay to slow icbm advance
counter:  .byte 12
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
          ;; introduce delay {
          dec counter
          beq begin
          rts
          ;; }
begin:    
          lda #6
          sta counter
          ldx #MAX_MISSILES   
loop:     
          cpx #MAX_LINES
          beq done
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
          ;; icbm was destroyed by a detonation
          ;; save its current location - we erase to this point in scratch1
          lda line_data_indices,x
          sta scratch1               
          li_reset_line               
          ;; erase it, up to where it is - we can't use li_deactive here
          ;; because the line isn't full
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
reached_target:     
          li_deactivate
          ldy #0
          lda (z_lstore),y           ;get target city
          mu_queue                   ;mushroom cloud
          ;; erase icbm trail and start city explosion, it doesn't matter
          ;; if a city was there or not, we run the explosion animation
          rts
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

;;; Get X coord of center of a city
;;; IN:
;;;   A: city #
;;; OUT:
;;;   Y: city #
.macro city_location
          tay
          lda pl_city_x_positions,y
          clc
          adc #9                        ;city width / 2 
.endmacro
.proc random_city
          lda #6
          sta sy_rand
          jsr rand_n 
          ;; random city # in A
          city_location
          sta z_x2
          lda #pl_city_basey
          sec
          sbc #detonation_height
          sta z_y2
          ;; Y = random city on exit
          rts
.endproc
;;; Creates the line definitions for 
;;; a attack wave
;;; todo: there are multiple waves per level
;;; so we need a function that captures that
;;; IN:
;;;   ?: possibly an argument for how many icbms are in this wave
;;; OUT:
;;;   line_data[..]: contains pre-rendered attack vector
;;;   line_data[0]: target city
.import li_full_render
.proc icbm_genwave1
          ;mov #line_data01,z_lstore
          ldx #MAX_LINES
loop:     
          dex
          li_setz_lstore
          ;; define incoming icbm left, right edge at 5 pixels
          lda #XMAX - 10
          sta sy_rand
          jsr rand_n
          clc
          adc #5
          sta z_x1                      ; icbm x origin
          lda #10                       ; icbm y origin
          sta z_y1
          ;; pick a target city
          jsr random_city
          tya                           ; store target city in line_data[0]
          ldy #0                        ; "
          sta (z_lstore),y              ; "
          li_lineto z_x1,z_y1,z_x2,z_y2 
          cpx #MAX_MISSILES
          bne loop
          rts
.endproc
;;; Generate an attack wave
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc icbm_genwave
          mov #line_data01,z_lstore
          ldx #1
;          li_lineto #10,#10,#89,#155
          lda #0                        ; select city 0
          ldy #0                        ; "
          sta (z_lstore),y              ; store target city data in line buffer
          city_location
          sta z_x2
          li_lineto #XMAX-1,#0,z_x2,#165
          rts
          ldx #1
loop:     
          jsr li_render_pixel
          bne loop

loop2:    
          jmp loop2
          rts

.endproc
