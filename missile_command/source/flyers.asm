.include "shape_draw.inc"
.include "sprite.inc"
.include "screen.inc"
.include "zerop.inc"
.include "system.inc"
.include "jstick.inc"
.include "sound.inc"

FL_BWITH = 11                           ;bomber sprite width
FL_OFF_SCREEN = SCRCOLS + 2             ;off screen to right

.export fl_init, fl_draw_all, fl_update_all 
.export fl_bomber_x, fl_bomber_x2, fl_bomber_y, fl_bomber_move, fl_bomber_tile, fl_next_bomber, fl_send_bomber

.data

bomber_shiftL: .byte  <(bomber0_shift0),<(bomber0_shift1),<(bomber0_shift2),<(bomber0_shift3),<(bomber0_shift4),<(bomber0_shift5),<(bomber0_shift6),<(bomber0_shift7)
bomber_shiftH: .byte  >(bomber0_shift0),>(bomber0_shift1),>(bomber0_shift2),>(bomber0_shift3),>(bomber0_shift4),>(bomber0_shift5),>(bomber0_shift6),>(bomber0_shift7)

ksat0_shiftL: .byte  <(ksat_0_shift0),<(ksat_0_shift1),<(ksat_0_shift2),<(ksat_0_shift3),<(ksat_0_shift4),<(ksat_0_shift5),<(ksat_0_shift6),<(ksat_0_shift7)
ksat0_shiftH: .byte  >(ksat_0_shift0),>(ksat_0_shift1),>(ksat_0_shift2),>(ksat_0_shift3),>(ksat_0_shift4),>(ksat_0_shift5),>(ksat_0_shift6),>(ksat_0_shift7)

ksat1_shiftL: .byte  <(ksat_1_shift0),<(ksat_1_shift1),<(ksat_1_shift2),<(ksat_1_shift3),<(ksat_1_shift4),<(ksat_1_shift5),<(ksat_1_shift6),<(ksat_1_shift7)
ksat1_shiftH: .byte  >(ksat_1_shift0),>(ksat_1_shift1),>(ksat_1_shift2),>(ksat_1_shift3),>(ksat_1_shift4),>(ksat_1_shift5),>(ksat_1_shift6),>(ksat_1_shift7)

;.bss
.segment "CASS"

fl_next_bomber:     .res 1
fl_bomber_x:        .res 1              ;0 - 7 in tile
fl_bomber_x2:       .res 1              ;old location to erase
fl_bomber_y:        .res 1              ;y location on screen
fl_bomber_move:     .res 1              ;movement direction 0=right 1=left
;;; type of flyer: 0=bomber, 1=ksat0, 2=ksat1
fl_bomber_type:     .res 1            
fl_bomber_tile:     .res 1
fl_bomber_tile2:    .res 1
fl_savex:           .res 1
fl_savea:           .res 1

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
;;; the barely left part of the screen
;;; for example if the sprite's pixel location was 0-7
;;; then the rightmost tile ( stored in X ) would be 0
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
.export setup_from_right
.proc setup_from_right
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

          rts

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

          rts
.endproc
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

          rts
.endproc

;;; Put flyer pixels on screen
;;; IN:
;;;   A: flyer to render, 0=bomber 1=ksat0, 2=ksat1
;;;   X: shift to render
;;;   Y: y coordinate
;;; OUT:
.proc fl_render
.ifdef CHECKED_BUILD
          sta fl_savea
          cpx #8
          bgte ok
          abort 'E',55
ok:       
          lda fl_savea
.endif
          lda fl_bomber_type
          bne sat
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
;;; Draw any flyers that are currently on screen
;;; erase at old position, draw at new
;;; IN:
;;;   X: the flyer to draw 0 or 1
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc fl_draw_all
          lda frame_cnt                 ;fliers only move once 3 frames
          and #3
          bne done
          ;; on screen?
          lda fl_bomber_tile2           ;255-25 | 25-25, offscreen if either value
          cmp #FL_OFF_SCREEN
          blte draw                      ;nothing to erase
          ;; erase old location
          asl                           ;*2
          tay
          jsr setup_from_right

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
          blte done                      ;nothing to draw
          ;; draw at new location
          asl                           ;*2
          tay
          jsr setup_from_right
          ldy fl_bomber_y
          lda fl_bomber_x
          stx fl_savex
          tax
          jsr fl_render
          ldx fl_savex                  ;restore x
done:     
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
          lda fl_bomber_tile
          cmp #FL_OFF_SCREEN
          blte done

          lda fl_bomber_x
          sec 
          sbc #1
          bmi dec_tile
          sta fl_bomber_x
          jmp done
dec_tile: 
          dec fl_bomber_tile
          lda #7
          sta fl_bomber_x
done:     
.endmacro
;;; Move right
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.macro move_right
.local done,inc_tile
          lda fl_bomber_tile
          cmp #FL_OFF_SCREEN
          blte done

          lda fl_bomber_x
          clc 
          adc #1
          cmp #8
          beq inc_tile
          sta fl_bomber_x
          jmp done
inc_tile: 
          inc fl_bomber_tile
          lda #0
          sta fl_bomber_x
done:     
.endmacro

;;; Update screen locations of flyer
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc fl_update_all
          lda frame_cnt                 ;fliers only move once 4 frames
          and #3
          bne next
          ;; move current location to old location
          lda fl_bomber_tile
          sta fl_bomber_tile2
          cmp #FL_OFF_SCREEN
          beq next                      ;not active, don't update
          lda fl_bomber_x               ;double buffer location
          sta fl_bomber_x2
          ;; update current location
          lda fl_bomber_move            ;direction?
          bne left                      ;if left move left
          move_right                    ;else move right
          rts
left:          
          move_left
next:     
          rts
.endproc

.macro fl_flyer_height
          lda zp_lvl
          ;; if lvl > 8 then lvl = 8
          and #%111
          tax                           ;x=level s.t. level < 8
          jsr rand_8
          and #%11111                    ;0-31
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

          ;so_bomber_out

          ;; set height from table
          fl_flyer_height
          sta fl_bomber_y

          ldy #0                        ;fl_bomber_type=0
          jsr rand_8                    ;get a random number
          bmi bomber                    ;use high bit to decide bomber/satellite
          iny                           ;fl_bomber_type=1
bomber:   
          sty fl_bomber_type
          and #1
          sta fl_bomber_move
          bne left
          ;; left to right
right:    
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
