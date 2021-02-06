.include "jstick.inc"
.include "system.mac"
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "screen.inc"
.include "interceptor.inc"
.include "zerop.inc"
.include "sprite.inc"
.include "shapes.inc"
.import _ldata1
.export   move_crosshairs,update_crosshairs
.data
trigger_count:      .byte 0
.code

          .macro mov_l
          .local done
          lda #0
          cmp s_x
          beq done
          dec s_x
done:
          .endmacro

          .macro mov_r
          .local done
          lda #(SCRCOLS*8)-8-1
          cmp s_x
          bcc done
          inc s_x
done:
          .endmacro

          .macro mov_d
          .local done
          lda #SCRROWS*16-8-1
          cmp s_y
          bcc done
          inc s_y
done:
          .endmacro

          .macro mov_u
            .local done
          lda #0
          cmp s_y
          beq done
          dec s_y
done:
          .endmacro
.bss
draw_crosshair:     .res 1
.code
.proc     update_crosshairs
          lda #1
          sta draw_crosshair
          ldx #S_TARGET
          sp_draw crosshair, 5          ;erase

          ldx #S_TARGET
          jsr move_crosshairs

          lda draw_crosshair
          beq done
          ldx #S_TARGET
          sp_draw crosshair,5           ;draw
done:
          rts
.endproc
.proc     move_crosshairs
          jsr j_read
          and #bJOYT
          bne notrigger
          lda trigger_count
          ora #1
          sta trigger_count
          jmp directions
notrigger:
          lda trigger_count
          beq directions
          lda #0
          sta trigger_count
          ;; leave a 'x' marks the spot
          ;; at launch site
          sp_draw crosshair, crosshair_height
          jsr interceptor::launch
directions:
          lda LASTJOY
          ora #bJOYT
          cmp #JOYU
          beq joyu
          cmp #JOYD
          beq joyd
          cmp #JOYL
          beq joyl
          cmp #JOYR
          beq joyr
          cmp #JOYR & JOYU
          beq joyru
          cmp #JOYL & JOYU
          beq joyul
          cmp #JOYL & JOYD
          beq joydl
          cmp #JOYR & JOYD
          beq joyrd
          rts
joyrd:
          mov_r
          mov_d
          rts
joyru:
          mov_r
          mov_u
          rts
joydl:
          mov_d
          mov_l
          rts
joyul:
          mov_u
          mov_l
          rts
joyd:
          mov_d
          rts
joyu:
          mov_u
          rts
joyr:
          mov_r
          rts
joyl:
          mov_l
          rts
.endproc
