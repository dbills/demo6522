;;; produces the attract screen
;.include "zerop.inc"
.include "screen.inc"
.include "system.inc"
.include "m16.mac"
.include "math.inc"

.export bigx, bigy, bigplot, bigletter, bigstring, bi_mcommand
.data
;;; custom character set codes:
;;; ---------------------------
;;;  abcdefghijklmnopqrstuv
;;; $123456789abcdef1111111
;;; $               0123456
message1: .byte   13,    9,   19,  19,   9, 12,    5, 0
message2: .byte  $03,  $0f,  $0e, $14, $12, $0f, $0c, 0
lwidth:   .byte 3
.segment "BSS"
bigx:     .res 1
bigy:     .res 1
counter1: .res 1
counter2: .res 1
charrow:  .res 1
.bss
bigwidth = 7
left_offset = ( (XMAX / 3) / 2 )- ( ( bigwidth * 7 ) / 2 )
.zeropage
chrom1:   .res 2
msg1:     .res 2
.code

.proc       bi_mcommand
            lda #left_offset
            sta bigx
            lda #11
            sta bigy
            mov #message1, msg1
            jsr bigstring

            lda bigy
            clc
            adc #12
            sta bigy

            lda #left_offset
            sta bigx
            mov #message2, msg1
            jsr bigstring
            rts
.endproc

.proc       bigstring
            ldy  #0
loop:
            lda  (msg1),y
            beq done

            jsr bigletter

            ;; increment letter position
            lda bigx
            clc
            adc #7
            sta bigx
            ;; next letter
            iny
            jmp loop
done:
            rts
.endproc

.proc       bigletter
            sta factor1
            lda #8
            sta factor2
            saveall
            jsr mul8
            mov factor1, chrom1
            add #$8000, chrom1
            lda bigx
            pha
            lda bigy
            pha


            ldy #$ff
loop1:
            iny
            lda (chrom1),y
            sta charrow
            ldx #7
loop2:
            rol charrow
            bcc nextbit
            jsr bigplot
nextbit:
            inc bigx
            dex
            bpl loop2
            ;; y+=1 x-=8
            inc bigy
            sec
            lda bigx
            sbc #8
            sta bigx
            ;; next char row
            cpy #7
            bne loop1

            pla
            sta bigy
            pla
            sta bigx
            resall
            rts
.endproc
; 3 pixels per pixel
.proc       bigplot
            saveall
            lda bigx
            asl
            clc
            adc bigx
            sta _pl_x
            lda bigy
            asl
            clc
            adc bigy
            sta _pl_y

            lda lwidth
            sta counter1
xloop:
            lda lwidth
            sta counter2
drawx:
            jsr sc_plot
            inc _pl_x
            dec counter2
            bne drawx

            lda _pl_x
            sec
            sbc lwidth
            sta _pl_x

            inc _pl_y
            dec counter1
            bne xloop

            resall
            rts
.endproc
