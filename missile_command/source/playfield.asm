.include "sprite.inc"
.include "shapes.inc"
.include "m16.mac"
.include "zerop.inc"
.include "screen.mac"
.export draw_cities, city_base
.bss
city_base:  .res 1
.data
;;; note city shape has 4 empty pixels on left
left_metropolis_start = 3
right_metropolis_start = XMAX/2 + left_metropolis_start + 9
.define ground_partition_size 26
city_count: .byte 5
city_x_positions:
            .byte left_metropolis_start + ground_partition_size *0
            .byte left_metropolis_start + ground_partition_size *1
            .byte left_metropolis_start + ground_partition_size *2
            .byte right_metropolis_start + ground_partition_size *0
            .byte right_metropolis_start + ground_partition_size *1
            .byte right_metropolis_start + ground_partition_size *2
.code
;;; stack based args
;;; arg1 = pixels from bottom of screen to draw cities
.proc       draw_cities
            lda #8
            sta height
            mov #base_left,ptr_0
            lda #XMAX/2-8
            sta s_x
            ;lda #YMAX-9
            lda city_base
            sec
            sbc #4
            sta s_y
            jsr draw_unshifted_sprite
            lda #XMAX/2
            sta s_x
            mov #base_right,ptr_0
            jsr draw_unshifted_sprite

            lda #5
            sta height

            lda city_base
            sta s_y
loop:
            ldx city_count
            lda city_x_positions,x
            sta s_x
            mov #city_left,ptr_0
            jsr draw_unshifted_sprite
            clc
            lda #8
            adc s_x
            sta s_x
            mov #city_right,ptr_0
            jsr draw_unshifted_sprite
            dec city_count
            bpl loop
            rts
.endproc
