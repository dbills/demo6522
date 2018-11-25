        processor 6502
        org $1200               ;8K expansion
        
;;; some modulated notes
;;; 2 bytes, switches between them
E       equ     $cdce
D       equ     $c8c8        
D_s     equ     $cbcb
B       equ     $bdbf
C_s     equ     $c5c5
A       equ     $b5b6
C       equ     $c0c3

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

CNOTEP  equ     $F8             ;note 1/2 pointer
CNOTEI  equ     $F9             ;current note index
CNOTE1  equ     $FB             ;current note to play
CNOTE2  equ     $FC             ;interpolation note
CDUR_L  equ     $FD             ;note duration
CDUR_H  equ     $FE
        
VOICE   equ     36875
        
        lda #15
        sta 36878               ;volume to max
        lda #0
        sta CNOTEI              ;set start note index
        sta CNOTEP              ;trill note 1 first
        sta CDUR_H              ;set initial duration to 1 
        lda #1
        sta CDUR_L              ;of first note
        
        sei                     ;disable interrupts
        ;; 1MHz = 1/1,000,000s
        ;; x = 1e06/120 => x = 8333 cycles
HZ800   equ     $4e2        
HZ400   equ     $9c4
HZ120   equ     $208d           ; 1/120th
HZ30    equ     $8235           ; 1/30th
HZ60    equ     $411A           ; 1/60th
HZ16    equ     $f424           ; 1/16th
        ;; load countdown value into via 2, timer1 latch
        store16 HZ400, $9124
        ;; install our own interrupt handler for IRQ
        store16 INTR, $314

        cli                     ;enable interrupts
        ;; do nothing, forever
.loop        
        nop
        jmp .loop
        
;;; our interrupt handler
INTR
        dec16 CDUR_L            ;decrement note duration
        beq .next_n             ;note is over

        ;; note still plays
        ldx CNOTEP              ;note a or b?
        lda CNOTE1,x            ;load it
        sta VOICE               ;play it
        lda #1                  ;switch note
        eor CNOTEP
        sta CNOTEP
        jmp $eb15               ;rti via OS minimal IRQ 
.next_n
        ldx CNOTEI
        cpx #[END-NOTES]
        bne .play    
        ldx #0                  ;reset to start
.play
        lda NOTES,x             ;get note1
        sta VOICE
        sta CNOTE1
        inx
        lda NOTES,x             ;get note2
        sta CNOTE2
        inx                     ;get duration low byte
        lda NOTES,x             
        sta CDUR_L              ;save current duration
        inx                     ;get duration high byte
        lda NOTES,x
        sta CDUR_H
        inx                     ;increment track index
        stx CNOTEI
.done
        jmp $eb15               ;rti via OS minimal IRQ 

NOTES
        dc.w E   ,60
        dc.w D_s ,60
        dc.w E   ,60
        dc.w D_s ,60
        dc.w E   ,60
        dc.w B   ,60
        dc.w D   ,60
        dc.w C   ,60
        dc.w A   ,240
END      
p
