.include "system.mac"
.export _sleep, rand_8, i_rand
.data
seedlo:    .res 1
seedhi:    .res 1
.code
.proc _sleep
loop:
          waitv
          dex
          bne loop
          rts
.endproc

; returns pseudo random 8 bit number in A. Affects A. (r_seed) is the
; byte from which the number is generated and MUST be initialised to a
; non zero value or this function will always return zero. Also r_seed
; must be in RAM, you can see why......
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
.proc     rand_8
lda seedhi
  lsr
  rol seedlo
  bcc noeor
  eor #$B4
noeor:
  sta seedhi
  eor seedlo
  RTS
.endproc
