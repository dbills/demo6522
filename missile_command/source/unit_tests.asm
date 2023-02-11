.ifdef TESTS
.include "text.inc"

.code
.export unit_tests
.proc unit_tests
          ;; initialize test data
          lda #0
          sta s_x
          sta s_y
          myprintf "running tests"
          
          rts
.endproc
.endif
