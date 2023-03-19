.include "shape_draw.inc"
.include "sprite.inc"
.include "screen.inc"
.include "zerop.inc"
.include "system.inc"
.include "jstick.inc"

.export fl_draw, fl_test, fl_init
.data

bomber_shiftL: .byte  <(bomber0_shift0),<(bomber0_shift1),<(bomber0_shift2),<(bomber0_shift3),<(bomber0_shift4),<(bomber0_shift5),<(bomber0_shift6),<(bomber0_shift7)
bomber_shiftH: .byte  >(bomber0_shift0),>(bomber0_shift1),>(bomber0_shift2),>(bomber0_shift3),>(bomber0_shift4),>(bomber0_shift5),>(bomber0_shift6),>(bomber0_shift7)

.bss

fl_bomber_x:           .res 1
.code

.proc fl_init
          lda #150
          sta fl_bomber_x
          rts
.endproc

.proc fl_draw
          lda fl_bomber_x
          sp_calc_screen_column
          tay
          sp_setup_draw
          lda fl_bomber_x
          and #$7
          tax
          ldy #50
          sy_dynajump bomber_shiftL, bomber_shiftH
.endproc

.proc fl_test
loop0:    
          waitv
          sc_update_frame
          lda frame_cnt
          cmp #7
          bne loop0
          jsr fl_draw
          dec fl_bomber_x
          beq reset
          jmp loop0
reset:    
          lda #160
          sta fl_bomber_x
          jmp loop0
          rts
.endproc
