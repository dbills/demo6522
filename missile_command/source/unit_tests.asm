.ifdef TESTS
.include "text.inc"
.include "detonation.inc"

.code
.export unit_tests
fubar1:    
          .asciiz "^J"
.proc unit_tests
          te_pos #0, #0
          ;te_printf "running tests"
          jsr de_unit_tests
          rts
.endproc
.endif
