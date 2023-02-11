.ifdef TESTS
.include "text.inc"
.include "detonation.inc"

.code
.export unit_tests
.proc unit_tests
          te_pos #0, #0
          myprintf "running tests"
          crlf
          myprintf "detonation"
          jsr de_unit_tests
          rts
.endproc
.endif
