          include "jstick.mac"
          include   "system.mac"

          mac mov_l
          lda #0
          cmp s_x,x
          beq .done
          dec s_x,x
.done
          endm

          mac mov_r
          lda #[SCRCOLS*8]-8-1
          cmp s_x,x
          bcc .done
          inc s_x,x
.done
          endm

          mac mov_d
          lda #SCRROWS*16-8-1
          cmp s_y,x
          bcc .done
          inc s_y,x
.done
          endm

          mac mov_u
          lda #0
          cmp s_y,x
          beq .done
          dec s_y,x
.done
          endm
          
moveme    subroutine
          jsr j_read
          cmp #JOYU
          beq .joyu
          cmp #JOYD
          beq .joyd
          cmp #JOYL
          beq .joyl
          cmp #JOYR
          beq .joyr
          cmp #JOYR & JOYU
          beq .joyru
          cmp #JOYL & JOYU
          beq .joyul
          cmp #JOYL & JOYD
          beq .joydl
          cmp #JOYR & JOYD
          beq .joyrd
          cmp #JOYT
          beq .joyt
          cmp #JOYT & JOYR
          beq .joyrt
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
          rts
.joyt
          ;jsr j_tup
          jsr j_tup
          jsr lineto
          rts
.joyrt
          jsr lineto
          mov_r
          rts

;;; inputs: x sprite to draw line to
lineto    subroutine
          saveall
          ;; set x1,x2,y1,y2
          ;lda #0
          lda #175/2
          sta x1
          lda #0
          sta y1
          lda s_x,x
          sta x2
          lda s_y,x
          sta y2

          movi ldata1-1,lstore
          jsr genline
;          jsr line1
;          jsr render1
;          jsr line2
;          jsr render2
          resall
          rts

