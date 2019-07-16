          SEG       CODE
tmval     dc.b      
sleep_    subroutine
.l1                                     ;one second
          ldx #61
.l2                                     ;one 60th
          lda JIFFYL
.jif1          
          cmp JIFFYL
          beq .jif1

          dex
          bne .l2                       ;wait another jiffy
          dec tmval
          bne .l1                       ;wait another sec
          rts

          mac updjiffy
;        clc
          INC JIFFYL
          BNE .dd
          INC JIFFYM
          BNE .dd
          INC JIFFYH
.dd
          endm
