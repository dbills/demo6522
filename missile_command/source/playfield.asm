.include "sprite.inc"
.include "shapes.inc"
.include "m16.mac"
.include "zerop.inc"
.include "screen.mac"
.include "colors.equ"
.include "playfield.mac"

.export pl_draw_cities, pl_city_x_positions, pl_init

missile_base_width = 16
;;; note city shape has 4 empty pixels on left
city_margin = 4
city_width = 12
content_width = XMAX - (city_width * 6) - missile_base_width
spacing = content_width / 8

.bss
city_count: .res 1
pl_city_x_positions: .res 6
pl_base_x_position:  .res 1
.code
;;; proposed new city layout, this is not the current       
;;;  c  c  c  bbb  c  c  c
;;; 01234567890123456789012

;;; Initialize playfield data for start of game
;;; reset cities, and live city count
;;; IN:
;;; OUT:
.proc pl_init
          lda #5
          sta city_count
          ;; 6 cities + base + 1 = margins
          lda #spacing + (city_width+spacing)*0 - city_margin
          sta pl_city_x_positions
          lda #spacing + (city_width+spacing)*1 - city_margin
          sta pl_city_x_positions+1
          lda #spacing + (city_width+spacing)*2 - city_margin
          sta pl_city_x_positions+2
          lda #spacing + (city_width+spacing)*3 + 16 + spacing - city_margin
          sta pl_city_x_positions+3
          lda #spacing + (city_width+spacing)*4 + 16 + spacing - city_margin
          sta pl_city_x_positions+4
          lda #spacing + (city_width+spacing)*5 + 16 + spacing - city_margin
          sta pl_city_x_positions+5
          rts
.endproc
;;; Draw cities at bottom the screen.  This will need update to take into account
;;; cities that have been destroyed which will not have an x coord in 
;;; pl_city_x_positions
;;; 
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
;;; arg1 = pixels from bottom of screen to draw cities
.proc       pl_draw_cities
          ;; draw ground
          lda #255
          .repeat 23, COL
          sta CHBASE1 + (COL * SCRROWS * CHARHT) + YMAX - 3
          sta CHBASE1 + (COL * SCRROWS * CHARHT) + YMAX - 2
          sta CHBASE1 + (COL * SCRROWS * CHARHT) + YMAX - 1
          .endrepeat
          ;; lda #PURPLE
          ;; sta CLRRAM + (23 * (SCRROWS-1)) + SCRCOLS/2-1
          ;; sta CLRRAM + (23 * (SCRROWS-1)) + SCRCOLS/2
          ;; sta CLRRAM + (23 * (SCRROWS-1)) + SCRCOLS/2+1
          
          ;; draw missile base in center of screen
          lda #8
          sta sp_height
          mov #base_left,ptr_0
          lda #XMAX/2-8
          sta s_x
          lda #pl_city_basey            ;2 pixels above cities
          sec
          sbc #2
          sta s_y
          jsr sp_draw_unshifted
          lda #XMAX/2
          sta s_x
          sta pl_base_x_position
          mov #base_right,ptr_0
          jsr sp_draw_unshifted

          ;; draw the six cities
          lda #5
          sta sp_height
          lda #pl_city_basey
          sta s_y
loop:
          ldx city_count
          lda pl_city_x_positions,x
          sta s_x
          mov #city_left,ptr_0
          jsr sp_draw_unshifted
          ;; move 8 right, for right piece
          clc
          lda #8
          adc s_x
          sta s_x
          mov #city_right,ptr_0
          jsr sp_draw_unshifted
          dec city_count
          bpl loop
          rts
.endproc
