.include "system.mac"
.export _sleep, rand_8, i_rand
.data
r_seed:   .res 1
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
          sta r_seed
          rts
.endproc
.proc     rand_8
	LDA	r_seed		; get seed
	ASL			; shift byte
	BCC	no_eor		; branch if no carry

	EOR	#$CF		; else EOR with $CF
no_eor:
	STA	r_seed		; save number as next seed
	RTS			; done
.endproc
