.ifdef TESTS
.include "text.inc"
.include "detonation.inc"

.code
.export unit_tests
fubar1:    
          .asciiz "^J"
.proc unit_tests
          jsr de_unit_test_CY
          rts
.endproc
.endif
