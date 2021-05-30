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

          jsr i_pltbl
          jsr i_chrset
          jsr i_hires
          jsr i_joy
          jsr i_rand
          screenmem SCREEN

          ;; border colors
          invmode 1
          bcolor_i GREEN
          scolor_i BLACK

          jsr i_debug_screen

          jsr sound_init

          ;jsr draw_cities
          jsr interceptor::in_initialize
          jsr init_lines
          jsr i_detonation
          jsr interceptor::icbm_genwave
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
          jsr main_loop
          ;jsr line_tests
          ;jsr test_detonation
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
          lda #SCRROWS*16/2
          sta target_y
          lda #79
          sta target_x
          sp_draw crosshair, 5
loop:
          jsr wait_v
          bcolor_i CYAN
;          jsr draw_detonations
;          bcolor_i BLACK
          update_crosshairs
          ;jsr interceptor::queue_iterate_interceptor
          jsr interceptor::update_interceptors
          jsr interceptor::icbm_update
          jmp loop
          rts
.endproc

.proc     i_intr
          sei
          lda $bf                       ;eabf
          sta $0314
          lda $ea
          sta $0315
          cli
          rts
.endproc

.proc     init_lines
          ldx #MAX_LINES-1
loop:
          lda #0
          sta line_data_indices,x
          dex
          bpl loop
          rts
.endproc

.proc     line_tests
          mov #line_data01,_lstore
          lineto #176/2,#176-26,#70,#50
          ldx #0
          jsr _general_render
          rts
.endproc
