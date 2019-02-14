sleep_    subroutine
          clc
          adc JIFFYL
.gettime
          cmp JIFFYL
          bcc .gettime
          rts
