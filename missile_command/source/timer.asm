.include "system.mac"
.code
tmval:      .byte 0
          .macro updjiffy
            .local dd
;        clc
          INC JIFFYL
          BNE dd
          INC JIFFYM
          BNE dd
          INC JIFFYH
dd:
            .endmacro
