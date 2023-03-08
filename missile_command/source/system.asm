.include "system.mac"
.export _sleep, rand_8, i_rand, stack

.data
seedlo:    .res 1
seedhi:    .res 1
stack:    .res 1
.code

;;; Wait for a bit
;;; IN:
;;;   X: 60s of second to wait
;;; OUT:
.proc _sleep
loop:
          waitv
          dex
          bne loop
          rts
.endproc
;;; Inititialize random number generator
;;; IN:
;;; OUT:
;;;   A: random number
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
;;; Generate a pseudo-random number from 0-255
;;; IN:
;;; OUT:
;;;   A: random number
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
