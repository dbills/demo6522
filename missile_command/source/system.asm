.include "system.mac"
.export _sleep, rand_8, i_rand, stack
.data
seedlo:    .res 1
seedhi:    .res 1
stack:    .res 1
.code
.proc _sleep
loop:
          waitv
          dex
          bne loop
          rts
.endproc

;;; inititialize random number generator
.proc     i_rand
loop:
          lda VICRASTER
          beq loop
          cmp #41
          beq loop
          sta seedlo
          lda #41
          sta seedhi
          rts
.endproc
;;; Random byte
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc     rand_8
  lda seedhi
  lsr
  rol seedlo
  bcc noeor
  eor #$B4
noeor:
  sta seedhi
  eor seedlo
  rts
.endproc
