;;; level intermission and scoring
.include "jstick.inc"
.include "text.inc"
.include "screen.inc"
.include "interceptor.inc"
.include "system.inc"
.include "playfield.inc"

.export b2d

BONUS_Y = 50
MISSILE_Y = 70
CITY_Y = MISSILE_Y + 18
CITY_COL = 10
BONUS_X = 15
MISSILE_FREQ = 210
CITY_FREQ = 180
.export le_next_level
.segment "CASS"
click_delay:   .res 1
.data
bonus:    
.asciiz "bonus points"
.code
;;; init level 
;;; IN:
;;;   arg1: does this and that
.proc le_init
          rts
.endproc
;;; Make click sound for missile or city
;;; IN:
;;;   A: freq
;;; OUT:
.proc click_sound
          ;lda #210
          sta 36877
          sleep click_delay

          lda #0
          sta 36877
          lda click_delay
          clc
          adc #15
          sta click_delay
          sleep click_delay
          rts
.endproc
;;; Show unused missiles and cities
;;; update scores and difficulties for next level
.proc le_next_level
          lda #BONUS_X
          sta s_x
          lda #BONUS_Y
          sta s_y
          mov #bonus, ptr_string
          jsr te_draw

          ;; show unused missiles


          lda #BONUS_X + 10
          sta s_x
          lda #MISSILE_Y
          sta s_y

          lda in_mcount
          jsr b2d
          jsr te_number
          lda ones_place
          jsr te_number

          ;; draw missiles next to number
          
          lda s_x                       ;move to right a bit
          clc
          adc #4
          sta _pl_x                     ;x for missile
          lda s_y
          sta _pl_y                     ;y for missile

          ldx in_mcount
          ldx #30
loop:     

          ;; the sound routine is somewhat sync the screen raster
          ;; so this may not need any further attention
          lda #30
          sta click_delay
          lda #MISSILE_FREQ
          jsr click_sound

          lda #MISSILE_Y + 2
          sta _pl_y                     ;y for missile
          jsr draw_missile
          lda _pl_x
          clc
          adc #2
          sta _pl_x
          dex
          beq cities
          bne loop

cities:   
          lda #CITY_Y
          sta s_y
          lda #CITY_COL
          sta s_x

          ldx #6
loop2:    
          lda #45
          sta click_delay
          lda #CITY_FREQ
          jsr click_sound
          ldy s_x
          jsr pl_draw_city
          ;; move to right
          lda s_x
          clc
          adc #4
          sta s_x

          dex
          beq done
          bne loop2
          
done:     jmp done
          rts
.endproc
;;; Hand plot a missile
;;; 
;;; +01234
;;;  -----
;;; 1| X
;;; 2| X
;;; 3|X X
;;; 4|
;;; IN:
;;;   _pl_x, _pl_y: upper left of missile
;;; OUT:
.proc     draw_missile
          inc _pl_x
          jsr sc_plot 
          inc _pl_y
          jsr sc_plot 
          inc _pl_y
          dec _pl_x
          jsr sc_plot 
          inc _pl_x
          inc _pl_x
          jsr sc_plot
          rts
.endproc
;;; Binary to decimal
;;; IN:
;;;   A: number to convert
;;; OUT:
;;;   A: tens
;;;   ones_place: ones
.bss
ones_place:         .res 1
.code
.proc b2d
          ldx #0
          sta ones_place

          lsr
          ror ones_place
          lsr
          ror ones_place
          lsr
          ror ones_place
          ;; A is now 10s
          ;; finish shifting ones over
          lsr ones_place
          lsr ones_place
          lsr ones_place
          lsr ones_place
          lsr ones_place
          tax                           ;loop 'tens' times
          tay                           ;save 'tens' in Y
          ;; subtract 2 from ones_place ( the remainder ), once
          ;; for each 'tens place' we have
          lda ones_place
loop:     
          sec
          sbc #2
          dex
          beq done
          bne loop
done:     
          sta ones_place
          tya
          rts
.endproc
