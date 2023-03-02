.include "zerop.inc"
.include "mushroom_draw.inc"
.include "sprite.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "playfield.inc"
.include "mushroom.mac"

.export mu_test, mu_init, mu_frame_num, mu_screen_col

MAX_MUSHROOMS = pl_max_cities
MUSHROOM_Y = YMAX-23
END_FRAME = 11                          ;last frame of mushroom

.bss
mu_screen_col:         .res MAX_MUSHROOMS
mu_frame_num:          .res MAX_MUSHROOMS
.zeropage
mushroom_idx:       .res 1
.code

.proc mu_init
          ldx #MAX_MUSHROOMS-1
          lda #END_FRAME
loop:     
          sta mu_frame_num,x
          dex
          bpl loop
          rts
.endproc

.macro mushroom_update idx
.local loop, skip
          ldy #idx
loop:     
          lda mu_frame_num,y            ;animation frame
          cmp #END_FRAME
          beq skip

          tax                           ;save frame # in X

          clc                           ;inc frame
          adc #1
          sta mu_frame_num,y

          lda mu_screen_col,y           ;setup screen pointers
          tay
          sp_setup_draw
          
          ldy #MUSHROOM_Y             
          ;; Y=pixel X=frame #
          jsr draw_mushroom
          lda #1                        ;return 1
skip:     
.endmacro

;;; draw mushroom cloud
;;; IN:
;;;   Y: Y screen coord
;;;   X: frame of animation to draw
;;; OUT:
;;;
.proc draw_mushroom
          sy_dynajump mushroom_framesL,mushroom_framesH
.endproc

;;; ==========================================================================

.proc mu_test
start:    
          lda #17
          sta _pl_x
          lda #0   
          mu_queue
loop:     
          mushroom_update 0
          beq start

          ldy #240
waiter:   
          waitv
          dey
          bne waiter
          
          jmp loop
          rts
.endproc

.proc mu_test1
          ;; first city is at x=(8+9)=17
          ldy #17/8
          sp_setup_draw
start:    
          ldx #0
loop:     
          ;; Y coord
          ldy #YMAX-23
          jsr draw_mushroom
          ;jsr j_wfire
          ldy #240
waiter:   
          waitv
          dey
          bne waiter

          inx
          cpx #11
          bne loop
          jmp start
          rts
.endproc
