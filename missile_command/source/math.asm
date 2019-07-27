;;; prefixes
;;; w=word
;;; a=address
;;; b=bytes
;;; addition/subtraction operations are
;;; 2 or 3 argument
;;; here's some examples
;;; sub_ww: 2 arg word from word
;;; sub_wb: w arg byte from word
;;; sub_wbw: 3 args: byte from word, store in output word
;;; sub_aw: word from address
;;; sub_abw: byte from address, store in a output word

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
          ;; move {1} to {2}
          ;; subtracting byte 3
          mac sub_wbw
          sec
          lda [{1}]+0
          sbc [{3}]+0
          sta [{2}]+0
          lda [{1}]+1
          sbc #0
          sta [{2}]+1
          endm

          mac sub_abw
          sec
          lda #[{1}] & $ff            ; load low byte
          sbc [{2}]+0
          sta [{3}]+0
          lda #[{1}] >> 8             ; load high byte
          sbc #0
          sta [{3}]+1
          endm

          ;; move {1} to {2}
          ;; adding byte 3
          mac add_wbw
          clc                ;ensure carry is clear
          lda [{1}]+0        ;add the two least significant bytes
          adc {2}            ;
          sta [{3}]+0        ;... and store the result
          lda [{1}]+1        ;add the two most significant bytes
          adc #0             ;... and any propagated carry bit
          sta [{3}]+1        ;... and store the result    clc
          endm  

          mac mul16
          asl
          asl
          asl
          asl
          endm
