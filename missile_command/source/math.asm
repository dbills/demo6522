.export factor1, factor2, mul8
.bss
factor1:     .res 1
factor2:    .res 1
.code

.proc       mul8
	  LDA #0
	  LDX  #$8
	  LSR  factor1
loop:
	  BCC  no_add
	  CLC
	  ADC  factor2
no_add:
	  ROR
	  ROR  factor1
	  DEX
	  BNE  loop
	  STA  factor2
	  ; done, high result in factor2, low result in factor1
              rts
.endproc
