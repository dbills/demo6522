.include "sprite.inc"
.include "shapes.inc"
.include "m16.mac"
.include "zerop.inc"
.include "screen.mac"
.include "colors.equ"
.include "playfield.mac"
.include "shape_draw.inc"

.export pl_draw_cities, pl_city_x_positions, pl_init
.export pl_m9,pl_m8,pl_m7,pl_m6,pl_m5,pl_m4,pl_m3,pl_m2,pl_m1,pl_m0

missile_base_width = 16
;;; note city shape has 4 empty pixels on left
city_margin = 4
city_width = 12
content_width = XMAX - (city_width * 6) - missile_base_width
spacing = content_width / 8

.bss

city_count: .res 1

.data

pl_city_x_positions: 
.byte  1*8+6, 4*8+6, 7*8+6              ;west
.byte 14*8+6,17*8+6,20*8+6              ;east
.byte 10*8+4                            ;base

.code
;;; Initialize playfield data for start of game
;;; reset cities, and live city count
;;; IN:
;;; OUT:
.proc pl_init
          lda #5
          sta city_count
          rts
.endproc

;;; Draw city at location in Y, low elevation
;;; IN:
;;;   Y: screen column *2 to draw city in
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc draw_city
          ;ldy #2
          sp_setup_draw
          ldy #YMAX-12
          jsr mcity0_shift0
          rts
.endproc

;;; Draw cities at bottom the screen.  This will need update to take into account
;;; cities that have been destroyed which will not have an x coord in 
;;; pl_city_x_positions
;;; proposed new city layout, this is not the current
;;;  c  c  c  bbb c  c  c 
;;; 01234567890123456789012
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
          ;sta CHBASE1 + (COL * SCRROWS * CHARHT) + YMAX - 3
          sta CHBASE1 + (COL * SCRROWS * CHARHT) + YMAX - 2
          sta CHBASE1 + (COL * SCRROWS * CHARHT) + YMAX - 1
          .endrepeat
          ;; west side cities
          ldy #1*2
          jsr draw_city
          ldy #4*2
          jsr draw_city
          ldy #7*2
          jsr draw_city
          ;; east side
          ldy #14*2
          jsr draw_city
          ldy #17*2
          jsr draw_city
          ldy #20*2
          jsr draw_city
          ;; left edge elevation texture
          ldy #0
          sp_setup_draw
          ldy #YMAX-4
          lda #%11100000
          sta (sp_col0),y
          iny
          lda #%11110000
          sta (sp_col0),y
          iny
          lda #%11111001
          sta (sp_col0),y
          ;; right edge elevation texture
          ldy #44
          sp_setup_draw
          ldy #YMAX-5
          lda #%00011000
          sta (sp_col0),y
          iny
          lda #%01111000
          sta (sp_col0),y
          iny
          lda #%11111100
          sta (sp_col0),y
          iny
          lda #%11111110
          sta (sp_col0),y
          ;; 
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-16
          jsr mbase0_shift0
          rts
.endproc

;;; Draw missile base with 9 missiles
;;; IN:
;;; OUT:
.proc pl_m9
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-3
          jmp mbase1_shift0
.endproc
.proc pl_m8
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-3
          jmp mbase2_shift0
.endproc
.proc pl_m7
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-3
          jmp mbase3_shift0
.endproc
.proc pl_m6
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-3
          jmp mbase4_shift0
.endproc
.proc pl_m5
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-7
          jmp mbase5_shift0
.endproc
.proc pl_m4
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-7
          jmp mbase6_shift0
.endproc
.proc pl_m3
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-11
          jmp mbase8_shift0
.endproc
.proc pl_m2
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-11
          jmp mbase9_shift0
.endproc
.proc pl_m1
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-14
          jmp mbase10_shift0
.endproc
.proc pl_m0
          ldy #10*2                       ;start of base column 10
          sp_setup_draw
          ldy #YMAX-13
          jmp mbase1_shift0
.endproc
