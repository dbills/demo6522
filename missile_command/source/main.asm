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

          jsr draw_cities
          jsr interceptor::in_initialize
          jsr init_lines
          jsr i_detonation

.import test_detonation
.include "bigletter.inc"
foo:
          lda #0
          sta bigx
          sta bigy
          ;; jsr bigplot
          ;; lda #1
          ;; sta bigx
          ;; sta bigy
          lda #1
          ;jsr bigletter
          ;jsr bigstring
          jsr mcommand
          ;jsr main_loop
          ;jsr line_tests
          jsr test_detonation
          jmp loop
;          debug_string "missilecommandtheend"
loop:
          jsr j_wfire
          jsr show_debug_screen
          jsr j_wfire
          jsr i_hires
          jmp loop
          rts
.endproc
;;; fill screen with a tiled
;;; set of chars to allow bitmapped
;;; graphics
.proc     i_hires
          chbase CHBASE1
          setrows SCRROWS
          setcolumns SCRCOLS
          setleft 3
          tallchar
          ldy SCRMAP_SZ
          ;; fill screen with chars tile
          ;; pattern
loop:
          lda #YELLOW
          sta CLRRAM-1,y
          lda SCRMAP-1,y
          sta SCREEN-1,y
          dey
          bne loop
          rts
.endproc
;;; clear ram allocated to custom
;;; character set
.proc     i_chrset
          mov #CHBASE1, ptr_0
          ldy #0
          ldx #16                       ;# of pages
          lda #0                        ;AA is nice
loop:
          sta (ptr_0),y
          iny
          beq inch
          bne loop
inch:
          inc ptr_0 + 1
          dex
          beq done
          bne loop
done:
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
          jsr draw_detonations
;          bcolor_i BLACK
          update_crosshairs
          jsr interceptor::queue_iterate_interceptor

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
