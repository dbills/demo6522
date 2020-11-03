.include "system.mac"
            .CODE
tmval:      .byte 0
.proc     sleep_ 
l1:                                     ;one second
          ldx #61
l2:                                     ;one 60th
          lda JIFFYL
jif1:       
          cmp JIFFYL
          beq jif1

          dex
          bne l2                       ;wait another jiffy
          dec tmval
          bne l1                       ;wait another sec
          rts
.endproc
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
