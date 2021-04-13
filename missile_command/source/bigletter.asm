;.include "zerop.inc"
.include "screen.inc"
.include "system.inc"
.include "m16.mac"
.include "math.inc"

.export bigx,bigy,bigplot,bigletter,bigstring,mcommand
.data
bigx:         .res 1
bigy:         .res 1
counter1:      .res 1
counter2:      .res 1
charrow:    .res 1
message1:    .byte 13,9,19,19,9,12,5,0
message2:   .byte 3,15,13,13,1,14,4,0
bigwidth = 7
left_offset = ( (XMAX / 3) / 2 )- ( ( bigwidth * 7 ) / 2 )
.zeropage
chrom1:     .res 2
msg1:       .res 2
.code

.proc       mcommand
            lda #left_offset
            sta bigx
            lda #16
            sta bigy
            mov #message1, msg1
            jsr bigstring

            lda bigy
            clc
            adc #8
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

            lda #2
            sta counter1
xloop:
            lda #2
            sta counter2
drawx:
            jsr _plot
            inc _pl_x
            dec counter2
            bpl drawx

            lda _pl_x
            sec
            sbc #3
            sta _pl_x

            inc _pl_y
            dec counter1
            bpl xloop

            resall
            rts
.endproc
