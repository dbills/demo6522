          include "jstick.mac"

          mac mov_l
          lda #0
          cmp pl_x
          beq .done
          dec pl_x
.done
          endm
          mac mov_r
          lda #[SCRCOLS*8]-8
          cmp pl_x
          bcc .done
          inc pl_x
.done
          endm

          mac mov_d
          lda #SCRROWS*16-8-1
          cmp pl_y
          bcc .done
          inc pl_y
.done
          endm

          mac mov_u
          lda #0
          cmp pl_y
          beq .done
          dec pl_y
.done
          endm
          
moveme    subroutine
          jsr j_read
          cmp #JOYU
          beq .joyu
          cmp #JOYL
          beq .joyl
          cmp #JOYD
          beq .joyd
          cmp #JOYL&JOYU
          beq .joyul
          cmp #JOYR
          beq .joyr
          cmp #JOYL&JOYD
          beq .joydl
          cmp #JOYR&JOYD
          beq .joyrd
          cmp #JOYR&JOYU
          beq .joyru
          rts
.joyrd
          mov_r
          mov_d
          rts
.joyru
          mov_r
          mov_u
          rts
.joydl
          mov_d
          mov_l
          rts
.joyul
          mov_u
          mov_l
          rts
.joyd
          mov_d
          rts
.joyu
          mov_u
          rts
.joyr
          mov_r
          rts
.joyl
          mov_l
.skip
          rts
