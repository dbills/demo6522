.include "system.mac"
.export _sleep
.proc _sleep
loop:
          waitv
          dex
          bne loop
          rts
.endproc
