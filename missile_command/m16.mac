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

          mac mov_w
          txa
          pha
          asl                         ; x*2 since it's a word
          tax
          lda [{1}],x
          sta [{2}],x
          inx
          lda [{1}],x
          sta [{2}],x
          pla
          tax
          endm
