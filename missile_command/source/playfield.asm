.include "sprite.inc"
.include "shapes.inc"
.include "m16.mac"
.include "zerop.inc"
.include "screen.mac"
.include "colors.equ"
.export draw_cities, city_base, city_x_positions
.bss
.data
city_base:  .byte YMAX-9
missile_base_width = 16
;;; note city shape has 4 empty pixels on left
city_margin = 4
city_width = 12
content_width = XMAX - (city_width * 6) - missile_base_width
;;; 6 cities + base + 1 = margins
spacing = content_width / 8
city_count: .byte 5
city_x_positions:
            .byte spacing + (city_width+spacing)*0 - city_margin
            .byte spacing + (city_width+spacing)*1 - city_margin
            .byte spacing + (city_width+spacing)*2 - city_margin
            .byte spacing + (city_width+spacing)*3 + 16 + spacing - city_margin
            .byte spacing + (city_width+spacing)*4 + 16 + spacing - city_margin
            .byte spacing + (city_width+spacing)*5 + 16 + spacing - city_margin
.code
;;; arg1 = pixels from bottom of screen to draw cities
.proc       draw_cities
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
          
          ;jmp blarg
            lda #8
            sta sp_height
            mov #base_left,ptr_0
            lda #XMAX/2-8
            sta s_x
            ;lda #YMAX-9
            lda city_base
            sec
            sbc #2
            sta s_y
            jsr sp_draw_unshifted
            lda #XMAX/2
            sta s_x
            mov #base_right,ptr_0
            jsr sp_draw_unshifted

blarg:    
            lda #5
            sta sp_height
            lda city_base
            sta s_y
loop:
            ldx city_count
            lda city_x_positions,x
            sta s_x
            mov #city_left,ptr_0
            jsr sp_draw_unshifted
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
