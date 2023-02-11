.ifdef TESTS
.include "text.inc"

.code
.export unit_tests
.proc unit_tests
          te_pos #0, #0
          myprintf "running tests"
          
          rts
.endproc
.endif
