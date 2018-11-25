        ;; 16 bit decrement
        mac dec16
        lda  [{1}]+0            ;load lsb
        bne .notzero
        ;; double decrement needed
        dec [{1}]+1             ;dec msb
.notzero
        dec [{1}]+0             ;dec lsb
        beq .lsbzero
        bne .done
.lsbzero
        ;; lsb was 0, load msb, if it's also zero
        ;; the Z flag will correct for 16 bit number
        lda {1}+1               
.done        
        endm

        ;; 16 bit load address
        mac store16
        lda #[{1}] & $ff        ;load low byte
        sta {2}                 ;store low byte
        lda #[{1}] >> 8         ;load high byte
        sta [{2}]+1             ;store high byte
        endm

