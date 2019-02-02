          mac inc_w
          inc [{1}]+0
          bne .done
          inc [{1}]+1
.done
          endm

          mac dec_w
          lda  [{1}]+0
          bne .done
          dec [{1}]+1
.done
          dec [{1}]+0
          endm

          mac mov_w
          lda [{1}]
          sta [{2}]
          lda [{1}]+1
          sta [{2}]+1
          endm

          mac mov_wi
          lda #[{1}] & $ff    ; load low byte
          sta {2}             ; store low byte
          lda #[{1}] >> 8     ; load high byte
          sta [{2}]+1         ; store high byte
          endm

          mac cmp_w
          lda {1}+1
          cmp #{2} >> 8       ; load high byte
          bne .done
          lda {1}
          cmp #[{2}] & $ff    ; load low byte
.done     
          endm

;;; compare {1} with #{2}
;;; you can use beq,bne with this
          mac cmp_wi
          lda {1}+1
          cmp #{2} >> 8       ; load high byte
          bne .done
          lda {1}
          cmp #[{2}] & $ff    ; load low byte
.done        
          emdn

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

