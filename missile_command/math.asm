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

          mac add
          clc 
          lda {1}
          adc {2}
          sta {1}
          endm

          mac sub
          sec
          lda {1}
          sbc {2}
          sta {1}
          endm
          ;; modulo 8
          mac modulo8
          lda #%00000111
          and {1}
          endm
