;;; draw letters on the screen
.include "zerop.inc"
.include "sprite.inc"
.include "m16.mac"
.include "math.mac"
.export _LETTERS, draw_letter1, _draw_string
.data
left_byte:  .byte 0
right_byte: .byte 0
scratch:    .byte 0
shift:      .byte 0
.code
            ;; source byte in A
            ;; output:
            ;;   left_byte
            ;;   right_byte
.proc       create_sprite_line
            sta left_byte
            lda #0
            sta right_byte
            ldx shift
            beq done
loop:       
            lsr left_byte
            ror right_byte
            dex
            bpl loop
done:       
            rts
.endproc

.data
string1:    
.asciiz     "abcdefghijklmnopqrstuvwxyz"
letter_table:
OFFSET      .set 0
.repeat     26
            .byte OFFSET
OFFSET      .set OFFSET + 7
.endrep

string_offset:          
            .byte 0
.code
.proc       _draw_string
loop:       
            ldy string_offset
            lda string1,y
            beq done
            sec
            sbc #'a'
            tax
            lda letter_table,x

            clc
            adc #<(_LETTERS)
            sta ptr_0
            lda #>(_LETTERS)
            adc #0
            sta ptr_0+1

            jsr draw_letter

            inc string_offset
            lda #6
            clc
            adc s_x
            sta s_x
            jmp loop
done:       
            rts
.endproc

.proc draw_letter1
            lda #83
            sta s_y
            lda #0
            sta sx
            jsr _draw_string
            rts
.endproc

;; .proc       draw_letter1
;;             lda #83
;;             sta s_x
;;             sta s_y
;;             mov #_LETTERS, ptr_0
;;             jsr draw_letter
;;             rts
;; .endproc

.proc       draw_letter
            jsr calculate_hires_pointers
            ;; ptr_0, ptr_1 hires column  pointers
            ;; ptr_2 adjusted source bytes
            ldy s_y
            ;; calculate loop end in scratch
            tya
            clc
            ;; letters are only 7 tall
            adc #7
            sta scratch
loop:       
            modulo8 s_x
            sta shift
            lda (ptr_2),y
        	jsr create_sprite_line  
            lda left_byte
            eor (ptr_0),y
            sta (ptr_0),y
            lda right_byte
            eor (ptr_1),y
            sta (ptr_1),y
            iny
            cpy scratch
            bne loop
            rts
.endproc

.data
_LETTERS:    
	.byte  %00100000,%01010000,%10001000,%11111000,%10001000,%10001000,%10001000 ;A
	.byte  %11110000,%10001000,%10001000,%11110000,%10001000,%10001000,%11110000 ;B
	.byte  %01110000,%10001000,%10000000,%10000000,%10000000,%10001000,%01110000 ;C
	.byte  %11100000,%10010000,%10001000,%10001000,%10001000,%10010000,%11100000 ;D
	.byte  %11111000,%10000000,%10000000,%11100000,%10000000,%10000000,%11111000 ;E
	.byte  %11111000,%10000000,%10000000,%11100000,%10000000,%10000000,%10000000 ;F
	.byte  %01110000,%10001000,%10000000,%10111000,%10001000,%10001000,%01110000 ;G
	.byte  %10001000,%10001000,%10001000,%11111000,%10001000,%10001000,%10001000 ;H
            .byte  %01110000,%00100000,%00100000,%00100000,%00100000,%00100000,%01110000 ;I
	.byte  %00111000,%00010000,%00010000,%00010000,%00010000,%10010000,%01100000 ;J
	.byte  %10001000,%10010000,%10100000,%11000000,%10100000,%10010000,%10001000 ;K
	.byte  %10000000,%10000000,%10000000,%10000000,%10000000,%10000000,%11111000 ;L
	.byte  %10001000,%11011000,%10101000,%10101000,%10001000,%10001000,%10001000 ;M
	.byte  %10001000,%10001000,%11001000,%10101000,%10011000,%10001000,%10001000 ;N
	.byte  %00100000,%01010000,%10001000,%10001000,%10001000,%01010000,%00100000 ;O
	.byte  %11110000,%10001000,%10001000,%11110000,%10000000,%10000000,%10000000 ;P
	.byte  %00100000,%01010000,%10001000,%10001000,%10101000,%01010000,%00101000 ;Q
	.byte  %11110000,%10001000,%10001000,%11110000,%10010000,%10001000,%10000000 ;R
	.byte  %01110000,%10001000,%10000000,%01110000,%00001000,%00001000,%11110000 ;S
	.byte  %11111000,%00100000,%00100000,%00100000,%00100000,%00100000,%00100000 ;T
	.byte  %10001000,%10001000,%10001000,%10001000,%10001000,%10001000,%01110000 ;U
	.byte  %10001000,%10001000,%10001000,%10001000,%10001000,%01010000,%00100000 ;V
	.byte  %10001000,%10001000,%10001000,%10001000,%10101000,%11011000,%10001000 ;W
	.byte  %10001000,%10001000,%01010000,%00100000,%01010000,%10001000,%10001000 ;X
	.byte  %10001000,%10001000,%10001000,%01110000,%00100000,%00100000,%00100000 ;Y
	.byte  %11111000,%00001000,%00010000,%00100000,%01000000,%10000000,%11111000 ;Z
	;; digits
	.byte  %01110000,%10001000,%10001000,%10101000,%10001000,%10001000,%01110000
	.byte  %00100000,%01100000,%10100000,%00100000,%00100000,%00100000,%11111000
	.byte  %11110000,%00001000,%00001000,%00110000,%11000000,%10000000,%11111000
	.byte  %11110000,%00001000,%00001000,%01110000,%00001000,%00001000,%11110000
	.byte  %00010000,%00110000,%01010000,%10010000,%11111000,%00010000,%00010000
	.byte  %11111000,%10000000,%11100000,%00010000,%00001000,%00010000,%11100000
	.byte  %00000000,%00000000,%00000000,%00000010,%00000000,%00000000,%00000000
	.byte  %11111000,%00001000,%00010000,%00100000,%01000000,%01000000,%01000000
	.byte  %01110000,%10001000,%10001000,%01110000,%10001000,%10001000,%01110000
	.byte  %01110000,%10001000,%10001000,%01111000,%00001000,%00010000,%01100000
