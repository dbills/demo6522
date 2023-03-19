.include "shape_draw.inc"
.include "sprite.inc"
.include "screen.inc"
.include "zerop.inc"
.include "system.inc"
.include "jstick.inc"

FL_BWITH = 11                           ;bomber sprite width
FL_OFF_SCREEN = SCRCOLS + 3             ;off screen to right

.export fl_draw, fl_test, fl_init
.data

bomber_shiftL: .byte  <(bomber0_shift0),<(bomber0_shift1),<(bomber0_shift2),<(bomber0_shift3),<(bomber0_shift4),<(bomber0_shift5),<(bomber0_shift6),<(bomber0_shift7)
bomber_shiftH: .byte  >(bomber0_shift0),>(bomber0_shift1),>(bomber0_shift2),>(bomber0_shift3),>(bomber0_shift4),>(bomber0_shift5),>(bomber0_shift6),>(bomber0_shift7)

.bss
;;; 0 - 7 in tile
fl_bomber_x:        .res 1
;;; 
fl_bomber_tile:     .res 1
.code

;;; X = rightmost tile * 2 of sprite 
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
.proc setup_from_right
ROM=$8000                               ;no-op write to address
          ;; load pointers to rom to effectively be a no-op
          ;; high bytes only ( should be all that's needed )
          lda >ROM
          sta sp_col0+1
          sta sp_col1+1
          sta sp_col2+1

          cpx #0
          beq tile2                     ;show only right tile
          cpx #2                        ;show middle and right
          beq tile1
          ;; else show all
tile0:    
          lda pltbl-4,x
          sta sp_col0
          lda pltbl-3,x
          sta sp_col0+1
tile1:    
          lda pltbl-2,x
          sta sp_col1
          lda pltbl-1,x
          sta sp_col1+1
tile2:    
          lda pltbl,x
          sta sp_col2
          lda pltbl+1,x
          sta sp_col2+1
          rts
.endproc
;;; we need the ability to specify -16
;;; and +16 for screen x coordinates
.proc fl_init
          lda #0
          sta fl_bomber_x
          lda #FL_OFF_SCREEN
          sta fl_bomber_tile
          rts
.endproc

.proc fl_draw
          lda fl_bomber_tile
          cmp #FL_OFF_SCREEN
          beq done                      ;not flying
          asl                           ;*2
          tax
          jsr setup_from_right

          lda fl_bomber_x
          and #$7
          tax
          ldy #50
          sy_dynajump bomber_shiftL, bomber_shiftH
done:     
          rts
.endproc

.proc move_right
          lda fl_bomber_tile
          cmp #FL_OFF_SCREEN
          beq done

          ldy fl_bomber_x
          iny
          cpy #8
          beq inc_tile
          sty fl_bomber_x
          rts
inc_tile: 
          inc fl_bomber_tile
          lda #0
          sta fl_bomber_x
done:     
          rts
.endproc
.proc fl_test
          lda #1
          sta fl_bomber_tile
          lda #0
          sta fl_bomber_x
loop:     
          jsr fl_draw
          jsr j_wfire
          jsr fl_draw
          jsr move_right
          jmp loop
for:         
          jmp for
          rts
.endproc
