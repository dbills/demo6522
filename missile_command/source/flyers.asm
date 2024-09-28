.include "shape_draw.inc"
.include "sprite.inc"
.include "screen.inc"
.include "zerop.inc"
.include "system.inc"
.include "jstick.inc"
.include "sound.inc"
.include "detonation.inc"

FL_BWITH = 11                           ;bomber sprite width
FL_OFF_SCREEN = SCRCOLS + 2             ;off screen to right

.export fl_init, fl_draw_all, fl_update_all, fl_send_bomber, fl_collision
.export cw2_s, cw2_e
.exportzp fl_next_bomber

.data

bomber_shiftL: .byte  <(bomber0_shift0),<(bomber0_shift1),<(bomber0_shift2),<(bomber0_shift3),<(bomber0_shift4),<(bomber0_shift5),<(bomber0_shift6),<(bomber0_shift7)
bomber_shiftH: .byte  >(bomber0_shift0),>(bomber0_shift1),>(bomber0_shift2),>(bomber0_shift3),>(bomber0_shift4),>(bomber0_shift5),>(bomber0_shift6),>(bomber0_shift7)

ksat0_shiftL: .byte  <(ksat_0_shift0),<(ksat_0_shift1),<(ksat_0_shift2),<(ksat_0_shift3),<(ksat_0_shift4),<(ksat_0_shift5),<(ksat_0_shift6),<(ksat_0_shift7)
ksat0_shiftH: .byte  >(ksat_0_shift0),>(ksat_0_shift1),>(ksat_0_shift2),>(ksat_0_shift3),>(ksat_0_shift4),>(ksat_0_shift5),>(ksat_0_shift6),>(ksat_0_shift7)

ksat1_shiftL: .byte  <(ksat_1_shift0),<(ksat_1_shift1),<(ksat_1_shift2),<(ksat_1_shift3),<(ksat_1_shift4),<(ksat_1_shift5),<(ksat_1_shift6),<(ksat_1_shift7)
ksat1_shiftH: .byte  >(ksat_1_shift0),>(ksat_1_shift1),>(ksat_1_shift2),>(ksat_1_shift3),>(ksat_1_shift4),>(ksat_1_shift5),>(ksat_1_shift6),>(ksat_1_shift7)

;.bss
;.segment "CASS"
.zeropage
fl_next_bomber:     .res 1
fl_bomber_x:        .res 1              ;0 - 7 in tile, from the left
fl_bomber_x2:       .res 1              ;old location to erase
fl_bomber_y:        .res 1              ;y location on screen
fl_bomber_dir:     .res 1              ;movement direction 0=right 1=left
fl_bomber_delay:    .res 1              ;movement delay bomber=3 ksat=2
;;; type of flyer: 0=bomber, 1=ksat0, 2=ksat1
fl_bomber_type:     .res 1              ;0=sat else bomber
;;; the right most tile of the sprite
fl_bomber_tile:     .res 1
fl_bomber_tile2:    .res 1
fl_savex:           .res 1
fl_savea:           .res 1
fl_deltax:          .res 1
fl_collision_delay: .res 1              ;pause before erasing after destruction
fl_bomber_speed:    .res 1              ;frame speed for bomber

;;; Arcade flyer performance table.  Arcade height is 230
;;; --------------------------------------------------------------------------
;;; lvl   height              cooldown   fire rate
;;; --------------------------------------------------------------------------
;;; 1	no fliers allowed 	-	-
;;; 2	+48 (148-195) 	240	128
;;; 3	+48 (148-195) 	160	96
;;; 4	+32 (132-163) 	128	64
;;; 5	+32 (132-163) 	128	48
;;; 6	+0 (100-131) 	96	32
;;; 7	+0 (100-131) 	64	32
;;; 8	+0 (100-131) 	32	16
.data
;;; size of all difficulty tables
FL_DIFFICULTY_T_SZ = 8
FL_BASE_Y = 40
fl_cooldown_t:      
.byte 240,160,128,18,96,64,32
fl_fire_t:          
.byte 128,96,64,48,32,32,16,16
;;; base range is 76 - 100.  An offset is added to height to make it easer at lower levels
;;; height = FL_BASE_Y + rand(32) + fl_range_t[current_level]
fl_range_t:          
.byte 0,0,0,24,24,36,36,36
.code
;;; Y = rightmost tile * 2 of sprite 
;;; i.e. 0 would draw the shift=7, third column of our 16x16 sprites on the 
;;; the barely left part of the screen. I.e: a one pixel strip of the shape.
;;; For example if the sprite's pixel location was 0-7
;;; then the rightmost tile # ( stored in X ) would be screen-column 0 
;;; Let P = pixel pos
;;;                           tile in X      
;;;    off screen            0 <- pixel 0
;;; -----------------+-------+----------
;;;          |       |       |
;;;          |       |       |sp_col3
;;;          |       |sp_col2|sp_col3
;;;          |sp_col1|sp_col2|sp_col3
;;; 
;;; for off screen, we set the pointers to ROM where writes
;;; will have no effect
;;;
;;; todo: rename to sp_setup_draw_right
.macro setup_from_right
.local tile0L,tile1L,tile2L,tile1R,tile0R,done,ROM
ROM=$8000                               ;no-op write to address
          ;; load pointers to rom to effectively be a no-op
          ;; high bytes only ( should be all that's needed )
          lda >ROM
          sta sp_col0+1
          sta sp_col1+1
          sta sp_col2+1

          cpy #0
          beq tile2L                    ;show only right tile
          cpy #2                        ;show middle and right
          beq tile1L
          cpy #FL_OFF_SCREEN*2 -2
          beq tile0R
          cpy #FL_OFF_SCREEN*2 -4
          beq tile1R
          ;; else show all
tile0L:    
          lda pltbl-4,y
          sta sp_col0
          lda pltbl-3,y
          sta sp_col0+1
tile1L:    
          lda pltbl-2,y
          sta sp_col1
          lda pltbl-1,y
          sta sp_col1+1
tile2L:    
          lda pltbl,y
          sta sp_col2
          lda pltbl+1,y
          sta sp_col2+1
          bne done

tile1R:    
          lda pltbl-2,y
          sta sp_col1
          lda pltbl-1,y
          sta sp_col1+1
tile0R:   
          lda pltbl-4,y
          sta sp_col0
          lda pltbl-3,y
          sta sp_col0+1

done:     
.endmacro
;;; <description>
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc fl_init
          lda #FL_OFF_SCREEN
          sta fl_bomber_tile
          sta fl_bomber_tile2
          ;; zeroes
          lda #0
          sta fl_collision_delay
          sta fl_bomber_x
          sta fl_bomber_x2
          sta fl_deltax
          ;; end zeroes
          rts
.endproc

;;; Calculate the x position of the current bomber
;;; 
;;; IN:
;;; OUT:
;;;   A: x position of current flyer
.macro calc_bomber_x
          lda fl_bomber_tile
          sec
          sbc #2
          asl
          asl
          asl
          sec
          clc
          adc fl_bomber_x
.endmacro
;;; check for collision with a flyer (bomber)
;;; 
;;; IN:
;;;   pl_x,pl_y: point to check
;;; OUT:
;;;   de_hit: true if collision
.zeropage
fl_ksat_right_x:       
fl_collision_wingtip_x:  .res 1
;;; bottom of wingtip
fl_ksat_bottom_y:      
fl_collision_wingtip_y:  .res 1
fl_collision_tailfin_x:  .res 1
.code
.proc fl_collision
          lda fl_collision_delay
          beq ok_to_check
          sec
          sbc #1
          sta fl_collision_delay
          beq remove_flyer
          rts
remove_flyer:       
          lda #FL_OFF_SCREEN
          sta fl_bomber_tile
          rts
ok_to_check:        
          savex
          calc_bomber_x
          ldy fl_bomber_type
          beq fl_collision_ksat
          ;;check 4 points of bomber      
nosecone:
          sta de_checkx
          sta _pl_x
          adc #8
          sta fl_collision_wingtip_x
          adc #3
          sta fl_collision_tailfin_x
          ;; y coord
          lda fl_bomber_y
          clc
          adc #8
          sta _pl_y
          sta de_checky
          adc #8
          sta fl_collision_wingtip_y

          jsr de_check
          lda de_hit
          beq tailfin
          jmp fl_destroy_flyer
tailfin:   
          ;; y is the same, only update x
          lda fl_collision_tailfin_x
          sta de_checkx
          sta _pl_x
          jsr de_check
          lda de_hit
          beq wingtip_bottom
          jmp fl_destroy_flyer
wingtip_bottom:   
          lda fl_collision_wingtip_x
          sta _pl_x
          sta de_checkx
          lda fl_collision_wingtip_y
          sta de_checky
          sta _pl_y
          jsr de_check
          lda de_hit
          beq wingtip_top
          jmp fl_destroy_flyer
wingtip_top:   
          ;; x is the same, only update y
          lda fl_bomber_y
          sta de_checky
          sta _pl_y
          jsr de_check
          lda de_hit
          beq done
          jmp fl_destroy_flyer
done:     
          resx
          rts
fl_collision_ksat:
          ;; upper left
          sta de_checkx
          sta _pl_x
          clc
          adc #14
          sta fl_ksat_right_x
          ;; y coord
          lda fl_bomber_y
          sta _pl_y
          sta de_checky
          clc
          adc #14
          sta fl_ksat_bottom_y
          ;; top left
          jsr de_check
          lda de_hit
          beq top_right
          jmp fl_destroy_flyer
top_right:   
          lda fl_ksat_right_x
          sta de_checkx
          sta _pl_x
          jsr de_check
          lda de_hit
          beq bot_right
          jmp fl_destroy_flyer
bot_right:   
          lda fl_ksat_bottom_y
          sta _pl_y
          sta de_checky
          jsr de_check
          lda de_hit
          beq bot_left
          jmp fl_destroy_flyer
bot_left: 
          lda fl_bomber_x
          sta de_checkx
          sta _pl_x
          jsr de_check
          lda de_hit
          beq done
          jmp fl_destroy_flyer
.endproc

.proc fl_destroy_flyer
          jsr de_queue
          lda #0
          sta fl_deltax
          lda #19
          sta fl_collision_delay
          resx
          rts
.endproc

;;; Put flyer pixels on screen
;;; IN:
;;;   A: flyer to render, 0=bomber 1=ksat0, 2=ksat1
;;;   X: shift to render
;;;   Y: y coordinate
;;; OUT:
cw2_s:    
.proc fl_render
.ifdef CHECKED_BUILD
          sta fl_savea
          cpx #8
          bcc ok
          abort 'E',E_FL_RANGE
ok:       
          lda fl_savea
.endif
          lda fl_bomber_type
          beq sat
          sy_dynajump bomber_shiftL, bomber_shiftH ;rts
sat:      
          ;; animate the satellite blinky lights
          txa
          and #4
          beq frame1
          ;; ksat frame 0
          sy_dynajump ksat0_shiftL, ksat0_shiftH ;rts
frame1:
          sy_dynajump ksat1_shiftL, ksat1_shiftH ;rts
          
.endproc
cw2_e:    

;;; branch to _1 if this frame should not move the bomer
.macro    fl_skipper _1
.local done
          ldy fl_bomber_type
          bne check
          lda zp_3cnt
          bne _1
          beq done
check:   
          lda frame_cnt
          and #3
          bne _1
done:     
.endmacro
;;; Draw any flyers that are currently on screen
;;; erase at old position, draw at new
;;; IN:
;;;   X: the flyer to draw 0 or 1
;;; OUT:
;;;   X is clobbered
.proc fl_draw_all_done
          rts
.endproc
.proc fl_draw_all
          fl_skipper fl_draw_all_done
          ;; on screen?
          lda fl_bomber_tile2           ;255-25 | 25-25, offscreen if either value
          ;; ??? does this work because of signed byte ???
          cmp #FL_OFF_SCREEN
          blte draw                      ;nothing to erase
          ;; erase old location
          asl                           ;*2
          tay
          setup_from_right

          ldy fl_bomber_y
          lda fl_bomber_x2
          ldy fl_bomber_y
          stx fl_savex
          tax
          jsr fl_render
          ldx fl_savex                  ;restore x
draw:     
          lda fl_bomber_tile
          cmp #FL_OFF_SCREEN
          blte done2                    ;nothing to draw
          ;; draw at new location
          asl                           ;*2
          tay
          setup_from_right
          ldy fl_bomber_y
          lda fl_bomber_x
          stx fl_savex
          tax
          jsr fl_render
          ldx fl_savex                  ;restore x
done:     
          rts
done2:    
          so_bomber_gone
          rts
.endproc

;;; Move left
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.macro    move_left
.local done,dec_tile
          lda fl_bomber_x
          sec 
          sbc fl_deltax
          bmi dec_tile
          sta fl_bomber_x
          bpl done
dec_tile: 
          dec fl_bomber_tile
          lda #7
          sta fl_bomber_x
done:     
.endmacro
;;; Move a flyer to the right
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.macro move_right
.local done,inc_tile
          lda fl_bomber_x
          clc 
          adc fl_deltax
          cmp #8
          beq inc_tile
          sta fl_bomber_x
          bne done
inc_tile: 
          lda #0
          sta fl_bomber_x
          inc fl_bomber_tile
done:     
.endmacro

;;; Update screen locations of flyer
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc fl_update_all
          fl_skipper next                   ;skip if not correct frame
          ;; move current location to old location
          lda fl_bomber_tile
          sta fl_bomber_tile2
          cmp #FL_OFF_SCREEN
          blte next                     ;not active, don't update
          lda fl_bomber_x               ;double buffer location
          sta fl_bomber_x2
          ;; update current location
          lda fl_bomber_dir            ;direction?
          bne left                      ;if left move left
          move_right                    ;else move right
          jmp fl_collision              ;includes rts
left:          
          move_left
          jmp fl_collision              ;includes rts
next:     
          rts
.endproc

.macro fl_flyer_height
          lda zp_lvl
          ;; if lvl > 8 then lvl = 8
          and #%111
          tax                           ;x=level s.t. level < 8
          jsr rand_8
          and #%11111                   ;0-31
          ;; height = FL_BASE_Y + rand(32) + fl_range_t[current_level]
          clc 
          adc #FL_BASE_Y
          clc
          adc fl_range_t,x
.endmacro

.proc fl_send_bomber
          ;; lda zp_lvl
          ;; beq done
          lda zp_cnt2
          clc
          adc #$05
          sta fl_next_bomber
          ;; restore left/right move increment
          lda #1
          sta fl_deltax

          so_bomber_out

          ;; set height from table
          fl_flyer_height
          sta fl_bomber_y

          ldy #0                        ;fl_bomber_type=0
          jsr rand_8                    ;get a random number
          bmi bomber                    ;use high bit to decide bomber/satellite
          iny                           ;fl_bomber_type=1
bomber:   
          sty fl_bomber_type
          ;and #1                        ;reuse random number 
          lda #0
          sta fl_bomber_dir
          bne left
          ;; left to right
right:    
          ;; A=0
          sta fl_bomber_tile
          sta fl_bomber_x
          ;; send out a flyer from right to left
          rts
left:     
          lda #23
          sta fl_bomber_tile
          lda #7
          sta fl_bomber_x
          ;; send out a flyer from left to right
done:     
          rts
.endproc
