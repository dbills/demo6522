          mac sub_w
          sec
          lda {1}
          sbc {2}
          sta {1}
          lda {1}+1
          sbc {2}+1
          sta {1}+1
          endm

          mac add_w
          clc                     ;ensure carry is clear
          lda [{1}]+0             ;add the two least significant bytes
          adc [{2}]+0             ;
          sta [{1}]+0             ;... and store the result
          lda [{1}]+1             ;add the two most significant bytes
          adc [{2}]+1             ;... and any propagated carry bit
          sta [{1}]+1             ;... and store the result    clc
          endm

