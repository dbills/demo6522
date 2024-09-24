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
;;; 
;;; How are the delay counters represented?
;;; missile attack waves are withheld if highest ICMB is above a certtain level
;;; this tends to pace the attacks
;;; if the player blows up the icbm, then we can send more
;;; or if they are low, then we can send more

.include "line.inc"
.include "detonation.inc"
.include "m16.mac"
.include "screen.inc"
.include "zerop.inc"
.include "system.inc"
.include "playfield.inc"
.include "mushroom.inc"
.include "playfield.inc"
.include "m16.mac"
.include "math.mac"

.export ic_genwave,ic_update, sm_update_all, sm_draw_all, sm_send, sm_init, ic_init
.import  queue_offsetsL_interceptor, queue_offsetsH_interceptor

;;; The maximum number of icbm's we'll launch in a wave
;;; if we have the slots for them. If we don't this might be less.
;;; We decide to launch a wave when the highest missile is below a certain
;;; height.
wave_size = 3
trigger_height = 80
;;; height above a city that icbm targets
detonation_height = 5
;;; distance from left of city to it's centerline where icbms target
city_centerline = 9
.data
ic_icbm_cnt:                                      ;icbms per level
.byte 12,15,18,12,16
.byte 14,17,10,13,16
.byte 19,12,14,16,18
.byte 14,17,19,22 
;;; These are 8.8 fixed point quantites. That is:
;;; 2 signed bytes. The fractional portion being X/128
;;; Example. 1.5 decimal = $0140
ic_icbm_dlyH:                                     ;frame per icbm move
.byte $04, $02, $01, $01, $0
ic_icbm_dlyL:                                     ;frame per icbm move
.byte 104, 112,  96,   3, 80
ic_smart_cnt:                                     ;smart bombs per level
.byte 0,0,0,0,0
.byte 1,1,2,3,4
.byte 4,5,5,6,6
.byte 7,7,7,7
;;; generate a delay to slow icbm advance
.zeropage
delay_i:  .res 2                                  ;level specific delay
delay:    .res 2                                  ;current counter value
.bss
icbm_cnt: .res 1
.code

;;; <description>
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered

;;; Initialize the icbm module
;;; IN:
;;;   zp_lvl: current game level
;;; OUT:
;;;   delay 
.proc ic_init
          ldx zp_lvl
          ldx #0                                  ;REMOVEME
          lda ic_icbm_dlyL,x
          sta delay_i
          sta delay
          lda ic_icbm_dlyH,x
          sta delay_i+1
          sta delay+1
          rts
.endproc
;;; Draw one pixel for all enemy icbms active
;;; There is one array of line data for both icbm and player interceptors
;;; The first N are interceptors, the last N are icbms.
;;; We start at beginning of second half to MAX_LINES, which are the icbms
;;; 
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc     ic_update
          ;; update and check delay
          lda delay
          sec
          sbc #128
          sta delay
          bmi dec_h                              ;decrement high byte
          rts
dec_h:    
          lda delay+1
          beq begin
          sec
          sbc #1
          sta delay+1
          rts
begin:    
          ;; reset the delay counter
          ;; delay += delay_i                                  
          add_w delay, delay_i

          ;; loop begin
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
          ;; queue (another) detonation, pl_x,pl_y already set
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
          inx
          jmp loop
.endproc

.zeropage
sy_rand:  .res 1
.code
;;; Random number between 0-5
.proc rand_6
          jsr rand_8
          tay
          ;; pick [0,4}
          and #3
          sta sy_rand
          tya
          lsr
          lsr
          lsr
          ;; bit 0-> carry. add this bit, plus the carry
          ;; for the effect of random [0,2}
          and #1
          adc sy_rand
          rts
.endproc
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
;;;   A: x coord of city
;;;   Y: city #
.macro city_location
          tay
          lda pl_city_x_positions,y
.endmacro

.proc random_city
          jsr rand_6
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

;;; Choose a random atmospheric entry point
;;; define incoming icbm left, right edge at 5 pixels
;;; OUT:
;;;  z_x1, z_x2
.macro random_entry_point
          lda #XMAX - 10                ;10 from right
          sta sy_rand
          jsr rand_n
          clc
          adc #5                        ;shift 5 from left
          sta z_x1                      ; icbm x origin
          lda #0                        ; icbm y origin
          sta z_y1
.endmacro
;;; Creates the line definitions for 
;;; an attack wave
;;; todo: there are multiple waves per level
;;; so we need a function that captures that
;;; IN:
;;;   ?: possibly an argument for how many icbms are in this wave
;;; OUT:
;;;   line_data[..]: contains pre-rendered attack vector
;;;   line_data[0]: target city
.import li_full_render
.proc ic_genwave
          lda #wave_size
          sta icbm_cnt              ;don't launch more than this

          ldx #MAX_LINES
loop:     
          dex
          ;; check if slot is free
          lda line_data_indices,x
          bne skip_slot
          random_entry_point            ;into x1,x2
          ;; pick a target city
          li_setz_lstore                ; set line pointer to X register
          jsr random_city
          tya                           ; store target city in line_data[0]
          ldy #0                        ; "
          sta (z_lstore),y              ; "
          li_lineto z_x1, z_y1, z_x2, z_y2 
          ;; stop if we've sent the maximum icbm in a wave
          lda icbm_cnt
          sec
          sbc #1
          beq done
          sta icbm_cnt
skip_slot:          
          cpx #MAX_MISSILES
          bne loop
done:     
          rts
.endproc

;;; Smart Bombs
;;; This is using a tentative prototype of on-the-fly line calculation
;;; There generally only one slop type for the smart missiles
;;; whatever the Y length is ( the screen, I guess, do killer sattelites ever
;;; drop smart bombs? )
;;; we subtract the delta-x from the total Y length, each time, when that quantity
;;; goes zero, we move along the x-axis and then reset the error term
;;; An example:
;;; If a line is 4 pixels from the top of the screen to the bottom
;;; and only have to travel 2 pixels to the right.  I.e. delta-x is 2
;;;  01
;;;  --
;;; 1.
;;; 2.
;;; 3 .
;;; 4 .
;;; 
;;; delta-x = (1-0)+1 = 2
;;; then we must travel 2 Y pixels before we move right on pixel
;;; err = Y
;;; err -= delta-x
;;; if(err <=0 ) {
;;;   move x coordinate
;;;   err += Y
;;; }
.bss
oldx:     .res 1
oldy:     .res 1
curx:     .res 1
cury:     .res 1
sm_tx:    .res 1                        ;target x
sm_ty:    .res 1                        ;target y
sm_city:  .res 1
sm_dx:    .res 1                        ;delta between smart missile start and target
sm_dy:    .res 1
sm_err:   .res 1
sm_frame: .res 2
sm_speed: .res 2                        ;8.8 speed for this level
.code

.proc sm_init
          ldy zp_lvl
          lda ic_icbm_dlyL,y
          sta sm_speed
          sta sm_frame
          lda ic_icbm_dlyH,y
          sta sm_speed+1
          sta sm_frame+1
          rts
.endproc

.proc sm_send
          lda #2                        ;city 2
          sta sm_city
          city_location
          sta sm_tx

          lda #pl_city_basey
          sec
          sbc #detonation_height
          sta sm_ty

          lda #0
          sta oldx
          sta oldy
          sta curx
          sta cury

          jmp sm_calc_slope
.endproc

.proc sm_calc_slope
          li_delta curx,sm_tx,#1
          sta sm_dx
          
          li_delta cury,sm_ty,#2
          sta sm_dy
          sta sm_err
          rts
.endproc

.proc sm_draw_all
          sub16 #$100,sm_frame           ;substract 1.00 from sm_frame
          bpl done
          lda oldx
          sta _pl_x
          lda oldy
          sta _pl_y
          jsr sc_plot 

          lda curx
          sta _pl_x
          lda cury
          sta _pl_y
          jsr sc_plot 
done:     
          rts
.endproc


.proc sm_update_all
          lda sm_frame+1                ;do we update this frame?
          bpl done
          ;; update frame
          add sm_speed, sm_frame
          lda #255                      ;smart bomb is active
          cmp cury
          beq done
          ;; copy double buffering variables 
          lda curx
          sta oldx
          lda cury
          sta oldy
          ;; movement logic
          ;; check for detonation
          lda cury
          clc
          adc #3
          sta de_checky
          lda curx                      ;check 3 pixels farther down
          sta de_checkx
          jsr de_check
          lda de_hit
          beq regular_move
          ;; evasion
          dec cury
          rts
regular_move:       
          lda sm_err
          sec 
          sbc sm_dx
          bpl movey
movex:    
          inc curx
          clc
          adc sm_dy                     ;A=0 reset sm_err
movey:    
          sta sm_err
          lda cury
          cmp sm_ty
          beq target_reached
          clc
          adc #1
          sta cury
done:     
          rts       
target_reached:     
          lda #255
          sta cury
          rts
.endproc

.ifdef TESTS
.include "unit_tests.inc"
.include "text.inc"
.include "jstick.inc"

.bss
nommod:   .res 1
.code

.export ic_unit_test
;;; test random number generator
.proc     ic_unit_test
          jsr ic_init
          jsr sy_random                 ;init random numbers
start:    
          lda #6
          te_pos #0, #0
.repeat 10
          jsr rand_6
          sta sy_rand
          te_printf "r:%d", sy_rand
.endrepeat
          te_printf "press trigger"
          jsr j_wfire
          jsr sc_chrset
          jmp start
          rts
.endproc

.endif
