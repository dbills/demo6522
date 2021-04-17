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
.export   move_crosshairs
.data
trigger_count:      .byte 0
.code
          ;; crosshair inc
          .macro ch_inc b
          lda b
          clc
          adc #2
          sta b
          .endmacro

          .macro mov_l
          .local done
          lda #detonation_xoff
          cmp target_x
          beq done
          dec target_x
done:
          .endmacro

          .macro mov_r
          .local done
          lda #(SCRCOLS*8)-8-1-detonation_xoff
          cmp target_x
          bcc done
          ;inc target_x
          ch_inc target_x
done:
          .endmacro

          .macro mov_d
          .local done
          lda #SCRROWS*16-(8*3)-1
          cmp target_y
          bcc done
          inc target_y
done:
          .endmacro

          .macro mov_u
          .local done
          lda #8
          cmp target_y
          beq done
          dec target_y
done:
          .endmacro

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
joyrd:
          mov_r
          mov_d
          rts
.endproc
