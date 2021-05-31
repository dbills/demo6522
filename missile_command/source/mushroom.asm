.include "zerop.inc"
.include "mushroom_draw.inc"
.include "sprite.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"

.export test_mushroom
.data
mushrooms: .res 4
mushroom_size = 4
.code

.proc mushroom_init
          ldx #mushroom_size-1
          lda #255
loop:     
          sta mushrooms,x
          dex
          bpl loop
          rts
.endproc

.proc mushroom_update
          ldx #mushroom_size-1
loop:     
          
          dex
          bpl loop
          rts
.endproc
.proc test_mushroom
          ldy #0
          setup_draw
start:    
          ldx #0
loop:     
          ;; Y coord
          ldy #YMAX-13
          jsr draw_mushroom
          ;jsr j_wfire
          ldy #240
waiter:   
          waitv
          dey
          bne waiter

          inx
          cpx #19
          bne loop
          jmp start
          rts
.endproc

;;; X = frame to draw
;;; Y = y coord
.proc draw_mushroom
          dynamic_jump mushroom_framesL,mushroom_framesH
.endproc
