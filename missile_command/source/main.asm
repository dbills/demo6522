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
.include "debugscreen.inc"
.include "shapes.inc"
.include "playfield.inc"
.include "interceptor.inc"
.include "queue.inc"
.include "sound.inc"
.include "detonation.inc"
.include "icbm.inc"
.ifdef TESTS
.include "unit_tests.inc"          
.endif
;.segment "STARTUP"
;          jmp demo
          .CODE
.proc     demo
          ;; enabling interrupts really pisses the system off with
          ;; the screen and character configs I have
          sei
          ;; load countdown value into via 2, timer1 latch
          ;; mov #HZ400, $9124
          mov #sound_interrupt, $0314
          ;mov #MINISR, $0314
          ;mov_wi DEFISR, $0314          ;
          cli
          lda #8
          sta 36878

          jsr i_pltbl                   ;init plotting table
          jsr i_chrset                  ;init character set
          jsr i_hires                   ;init hi-res screen
          jsr i_joy                     ;init joystick
          jsr i_rand                    ;inti random numbers
          screenmem SCREEN              ;set VIC screen address

          ;; border colors
          invmode 1
          bcolor_i BLUE
          scolor_i CYAN

          jsr i_debug_screen

          jsr i_sound

          jsr draw_cities
          jsr interceptor::in_initialize
          jsr init_lines
          jsr i_detonation
.ifdef TESTS
          jsr unit_tests
.endif
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
          ;jsr test_detonation
.import test_mushroom
          ;jsr test_mushroom
loop:     jmp loop
          ;jsr line_tests
.import attract
            ;jsr attract
          ;; debug_string "rmissilecommandtheend"
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
          draw_target
loop:
          jsr wait_v
          update_frame                  ;update frame counter
;          bcolor_i CYAN
;          jsr process_detonations
;          bcolor_i BLACK
          update_crosshairs
          ;jsr interceptor::queue_iterate_interceptor
          ;jsr interceptor::update_interceptors
;;; try this, see if it works
          jsr icbm_update
;          jsr collisions
          jmp loop
          rts
.endproc
;;; initialize interrupt vector
.proc     i_intr
          sei
          lda $bf                       ;eabf
          sta $0314
          lda $ea
          sta $0315
          cli
          rts
.endproc


.proc     line_tests
          ldx #0
          mov #line_data01,_lstore
          ;lineto #176/2,#176-26, #160,#0
          lineto #160,#0,#176/2,#176-26
          jsr _general_render
          rts
.endproc
