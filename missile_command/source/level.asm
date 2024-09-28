;;; level intermission and scoring
.include "jstick.inc"
.include "text.inc"
.export blarg1
.segment "BSS"
blarg1:   .res 5
.code
.proc le_init
          sta blarg1
.endproc
