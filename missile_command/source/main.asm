;;; defines used for various program modes during development

;;; 
;;; end defines
;;; 

.include "screen.inc"
.include "zerop.inc"         ;must be near top
.include "timer.inc"
.include "m16.mac"
.include "colors.equ"
.include "line.inc"
.include "math.mac"
.include "system.inc"
.include "jstick.inc"
.include "kplane.mac"
.include "target.inc"
.include "sprite.inc"
.include "text.inc"
.include "dbgscreen.inc"
.include "shapes.inc"
.include "playfield.inc"
.include "interceptor.inc"
;.include "queue.inc"
.include "sound.inc"
.include "detonation.inc"
.include "icbm.inc"
.include "mushroom.inc"
.include "flyers.inc"

.ifdef TESTS
.include "unit_tests.inc"          
.endif

;          jmp demo
          .CODE
.proc     demo
          sei
          ;; load countdown value into via 2, timer1 latch
          mov #HZ120, $9124
          ;mov #HZ60, $9124
          mov #so_isr, $0314
          cli
          jsr sc_pltbl                   ;init plotting table
          jsr sc_chrset                  ;init character set
          jsr sc_hires                   ;init hi-res screen
          jsr i_joy                      ;init joystick
          jsr i_rand                     ;init random numbers
          sc_screenmem SCREEN            ;set VIC screen address

          ;; border colors
          sc_invmode 1
          sc_bcolor BLUE
          sc_scolor CYAN

          jsr ta_init
          jsr db_init
          jsr so_init
          jsr in_init
          jsr li_init
          jsr de_init
          jsr pl_init
          jsr mu_init
          jsr fl_init
.ifdef TESTS
          jsr unit_tests
forever:  jmp forever
.endif
          ;jsr so_test
          jsr pl_draw_cities
          ;; jsr bigplot
          ;; lda #1
          ;; sta bigx
          ;; sta bigy
          ;jsr bigletter
          ;jsr bigstring
          ;;jsr mcommand

          jsr icbm_genwave

          jsr main_loop                 

          ;jsr line_tests
          ;jsr de_test
          ;jsr fl_test

          ;jsr mu_test
loop:     jmp loop
          ;jsr line_tests
.import attract
            ;jsr attract

          rts
.endproc
;;; wait vertical blank
.export wait_v
.proc       wait_v
iloop:
          lda VICRASTER           ;load raster line
          bne iloop
          rts
.endproc

.proc     main_loop
          lda #YMAX/2
          sta target_y
          lda #XMAX/2
          sta target_x
          ta_draw
          ;jsr fl_send_bomber
          jsr sm_send
loop:
          waitv
          sc_update_frame                  ;update frame counter
          sc_bcolor BLACK
          jsr fl_draw_all
          jsr de_draw_all
          jsr sm_draw_all
          ta_update
          ;; end of time critical?
          mu_update 
          jsr de_update_all
          jsr fl_update_all
          jsr sm_update_all
          ;; animate player missiles
          jsr in_update
          ;; animate enemy missiles
          jsr icbm_update
          ;; send out flyers
          fl_check_flyer

          ;; end of loop, update performance counter in border color
          sc_bcolor PURPLE
          jmp loop
          rts
.endproc

