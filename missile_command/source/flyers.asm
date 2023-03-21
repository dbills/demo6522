.include "shape_draw.inc"
.include "sprite.inc"
.include "screen.inc"
.include "zerop.inc"
.include "system.inc"
.include "jstick.inc"
.include "sound.inc"

FL_BWITH = 11                           ;bomber sprite width
FL_OFF_SCREEN = SCRCOLS + 2             ;off screen to right

.export fl_draw, fl_test, fl_init, fl_draw_all, fl_update_all 
.export fl_bomber_x, fl_bomber_x2, fl_bomber_y, fl_bomber_move, fl_bomber_tile, fl_next_bomber

.data

bomber_shiftL: .byte  <(bomber0_shift0),<(bomber0_shift1),<(bomber0_shift2),<(bomber0_shift3),<(bomber0_shift4),<(bomber0_shift5),<(bomber0_shift6),<(bomber0_shift7)
bomber_shiftH: .byte  >(bomber0_shift0),>(bomber0_shift1),>(bomber0_shift2),>(bomber0_shift3),>(bomber0_shift4),>(bomber0_shift5),>(bomber0_shift6),>(bomber0_shift7)

ksat0_shiftL: .byte  <(ksat_0_shift0),<(ksat_0_shift1),<(ksat_0_shift2),<(ksat_0_shift3),<(ksat_0_shift4),<(ksat_0_shift5),<(ksat_0_shift6),<(ksat_0_shift7)
ksat0_shiftH: .byte  >(ksat_0_shift0),>(ksat_0_shift1),>(ksat_0_shift2),>(ksat_0_shift3),>(ksat_0_shift4),>(ksat_0_shift5),>(ksat_0_shift6),>(ksat_0_shift7)

ksat1_shiftL: .byte  <(ksat_1_shift0),<(ksat_1_shift1),<(ksat_1_shift2),<(ksat_1_shift3),<(ksat_1_shift4),<(ksat_1_shift5),<(ksat_1_shift6),<(ksat_1_shift7)
ksat1_shiftH: .byte  >(ksat_1_shift0),>(ksat_1_shift1),>(ksat_1_shift2),>(ksat_1_shift3),>(ksat_1_shift4),>(ksat_1_shift5),>(ksat_1_shift6),>(ksat_1_shift7)

.bss

fl_next_bomber:     .res 1
fl_bomber_x:        .res 2              ;0 - 7 in tile
fl_bomber_x2:       .res 2              ;old location to erase
fl_bomber_y:        .res 2              ;y location on screen
fl_bomber_move:     .res 2              ;movement direction 1=right 2=left
;;; type of flyer: 0=bomber, 1=ksat0, 2=ksat1
fl_bomber_type:     .res 2            
fl_bomber_tile:     .res 2
fl_bomber_tile2:    .res 2
fl_savex:           .res 1
fl_savea:           .res 1
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

          sta fl_bomber_tile + 1
          sta fl_bomber_tile2 + 1

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
          txa
          and #4
          beq frame1
          ;; ksat frame 0
          sy_dynajump ksat0_shiftL, ksat0_shiftH
frame1:                                 ;ksat frame 1
          sy_dynajump ksat1_shiftL, ksat1_shiftH
;; ksat:                                   ;killer sattelite
;;           sy_dynajump bomber_shiftL, bomber_shiftH
.endproc
;;; Draw any flyers that are currently on screen
;;; erase at old position, draw at new
;;; IN:
;;;   X: the flyer to draw 0 or 1
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc fl_draw
          ;; on screen?
          lda fl_bomber_tile2,x
          cmp #FL_OFF_SCREEN
          beq draw                      ;nothing to erase
          ;; erase old location
          asl                           ;*2
          tay
          jsr setup_from_right

          ldy fl_bomber_y,x
          lda fl_bomber_x2,x
          ldy fl_bomber_y,x
          stx fl_savex
          tax
          jsr fl_render
          ldx fl_savex                  ;restore x
draw:     
          lda fl_bomber_tile,x
          cmp #FL_OFF_SCREEN
          beq done                      ;nothing to draw
          ;; draw at new location
          asl                           ;*2
          tay
          jsr setup_from_right
          ldy fl_bomber_y,x
          lda fl_bomber_x,x
          stx fl_savex
          tax
          jsr fl_render
          ldx fl_savex                  ;restore x
done:     
          rts
.endproc

;;; Update screen locations of all flyers
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc fl_update
          ;; move current location to old location
          lda fl_bomber_tile,x
          sta fl_bomber_tile2,x
          cmp #FL_OFF_SCREEN
          beq next                      ;not active, don't update
          lda fl_bomber_x,x
          sta fl_bomber_x2,x
          ;; update current location
          lda fl_bomber_move,x          ;direction?
          beq left                      ;if left move left
          jsr move_right                ;else move right
          jmp next
left:          
          jsr move_left
next:     
          rts
.endproc

.proc fl_update_all
          lda frame_cnt                 ;fliers only move once 3 frames
          and #3
          bne done

          ldx #1
loop:     
          jsr fl_update
          dex
          bpl loop
done:     
          rts
.endproc

.proc fl_draw_all
          lda frame_cnt                 ;fliers only move once 3 frames
          and #3
          bne done

          ldx #1
loop:     
          jsr fl_draw
          dex
          bpl loop
done:     
          rts
.endproc
;;; Move right
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc move_right
          lda fl_bomber_tile,x
          cmp #FL_OFF_SCREEN
          blte done

          lda fl_bomber_x,x
          clc 
          adc #1
          cmp #8
          beq inc_tile
          sta fl_bomber_x,x
          rts
inc_tile: 
          inc fl_bomber_tile,x
          lda #0
          sta fl_bomber_x,x
done:     
          rts
.endproc
;;; Move left
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc move_left
          lda fl_bomber_tile,x
          cmp #FL_OFF_SCREEN
          blte done

          lda fl_bomber_x,x
          sec 
          sbc #1
          bmi dec_tile
          sta fl_bomber_x,x
          rts
dec_tile: 
          dec fl_bomber_tile,x
          lda #7
          sta fl_bomber_x,x
done:     
          rts
.endproc

.proc fl_test
          ;so_bomber_out
          ldx #0
          lda #23
          sta fl_bomber_tile,x
          lda #7
          sta fl_bomber_x,x
          lda #50
          sta fl_bomber_y,x
          lda #0
          sta fl_bomber_move,x
loop:     
          waitv
          sc_update_frame
          jsr fl_draw_all
          jsr fl_update_all
          ;jsr j_wfire
          jmp loop

          rts
.endproc
