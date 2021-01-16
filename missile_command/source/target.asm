.include "jstick.inc"
.include "system.mac"
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "screen.inc"
.include "interceptor.inc"
.import _ldata1
.export   move_crosshairs

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

.proc     move_crosshairs
          jsr j_read
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
          cmp #JOYT
          beq joyt
          cmp #JOYT & JOYR
          beq joyrt
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
joyt:
          jsr j_tup
          jmp interceptor::in_launch
joyrt:
          jsr interceptor::in_launch
          mov_r
          rts
.endproc
