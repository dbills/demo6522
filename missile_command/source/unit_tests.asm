.ifdef TESTS
.include "insertion_sort.inc"
.export unit_tests

.proc unit_tests
          jsr insertion_sort_tests
          rts
.endproc
.endif
