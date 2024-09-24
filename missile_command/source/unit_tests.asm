.ifdef TESTS
.include "text.inc"
.include "detonation.inc"
.include "icbm.inc"
.code
.export unit_tests
fubar1:    
          .asciiz "^J"
.proc unit_tests
          ;jsr de_unit_test_CY
          jsr ic_unit_test
          rts
.endproc
.endif
