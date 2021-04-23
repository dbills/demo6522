.include "zerop.inc"
.include "sprite.inc"
.include "shapes.inc"
.include "m16.mac"
.include "math.mac"
.include "system.inc"
.include "screen.mac"

.export _draw_string,_debug_string,text_x,text_y,_debug_number,_myprintf
;;; 7 pixel tall letters
.define TEXT_HEIGHT 7
.define TEXT_WIDTH 6
.bss
string_offset:   .byte 0
.data
text_x:     .byte 140
text_y:     .byte 30
blarg:      .word $abcd
string1:
.asciiz     "abcdefghijklmnopqrstuvwxyz012"
letter_table:
OFFSET      .set 0
.repeat     26
            .byte OFFSET
OFFSET      .set OFFSET + 7
.endrep

.code

;;; calculate pointer to given letter
;;; IN: A = letter
;;;     font: base addr of glyphs
;;;     ptr: zp pointer to set
;;; CLOBBERS: X
.macro      letter_pointer font,ptr
            tax
            lda letter_table,x

            clc
            adc #<(font)
            sta ptr
            lda #>(font)
            adc #0
            sta ptr+1
.endmacro


.proc       _draw_string
            lda #0
            sta string_offset
            lda #TEXT_HEIGHT
            sta height
loop:
            ldy string_offset
            lda (ptr_string),y
            beq done
            cmp #' '
            beq next
            sec
            sbc #'a'
            letter_pointer _LETTERS, ptr_0

            jsr draw_unshifted_sprite
next:
            inc string_offset
            lda #TEXT_WIDTH
            clc
            adc s_x
            sta s_x
            jmp loop
done:
            rts
.endproc

.proc       _myprintf
            init_varg
            lda #TEXT_HEIGHT
            sta height
            lda #$ff
            sta string_offset
loop:
            inc string_offset
            ldy string_offset
            lda (ptr_string),y
            bne notempty
            rts
notempty:
            cmp #'%'
            beq param
            cmp #' '
            beq advance
            cmp #'$'
            bne l1
            lda #1
            jmp symbol
l1:
            cmp #':'
            bne l2
            lda #0
            beq symbol                  ;branch always
l2:
            cmp #','
            bne l3
            lda #2
            bne symbol
l3:
            cmp #'a'
            bcc number
letters:
            sec
            sbc #'a'
draw:
            letter_pointer _LETTERS, ptr_0
            jsr draw_unshifted_sprite
advance:
            add8 #TEXT_WIDTH, s_x
            jmp loop
number:
            sec
            sbc #'0'                     ;todo move to macro below
            letter_pointer _NUMBERS, ptr_0
            jsr draw_unshifted_sprite
            jmp advance
symbol:
            letter_pointer _SYMBOLS, ptr_0
            jsr draw_unshifted_sprite
            jmp advance
param:
            inc string_offset
            ldy string_offset
            lda (ptr_string),y
            cmp #'d'
            beq show_byte
            cmp #'w'
            beq show_word
            ;; show 'E' for error
             lda #'e' - 'a'
            letter_pointer _LETTERS, ptr_0
            jsr draw_unshifted_sprite
            popw_varg ptr_0
            jmp advance
show_byte:
            popw_varg ptr_0
            ldy #0
            lda (ptr_0),y
            jsr _debug_number
            jmp loop
show_word:
            popw_varg ptr_0
            ldy #0
            lda (ptr_0),y
            pha
            iny
            lda (ptr_0),y
            jsr _debug_number
            pla
            jsr _debug_number
            jmp loop
.endproc
;;; IN: A = number to display
.proc       _debug_number
            pha
            ;; display high nibble
            lsr
            lsr
            lsr
            lsr
            letter_pointer _NUMBERS, ptr_0
            jsr draw_unshifted_sprite
            add8 #TEXT_WIDTH, s_x
            pla
            ;; display low nibble
            and #$0f
            letter_pointer _NUMBERS, ptr_0
            jsr draw_unshifted_sprite
            add8 #TEXT_WIDTH, s_x
            rts
.endproc

.proc       _debug_string
            saveall
            lda #175-7
            sta s_y
            lda #0
            sta s_x
            pushw ptr_0
            jsr _draw_string
            popw ptr_0
            resall
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
	.byte  %11110000,%10001000,%10001000,%11110000,%10010000,%10001000,%10001000 ;R
	.byte  %01110000,%10001000,%10000000,%01110000,%00001000,%00001000,%11110000 ;S
	.byte  %11111000,%00100000,%00100000,%00100000,%00100000,%00100000,%00100000 ;T
	.byte  %10001000,%10001000,%10001000,%10001000,%10001000,%10001000,%01110000 ;U
	.byte  %10001000,%10001000,%10001000,%10001000,%10001000,%01010000,%00100000 ;V
	.byte  %10001000,%10001000,%10001000,%10001000,%10101000,%11011000,%10001000 ;W
	.byte  %10001000,%10001000,%01010000,%00100000,%01010000,%10001000,%10001000 ;X
	.byte  %10001000,%10001000,%10001000,%01110000,%00100000,%00100000,%00100000 ;Y
	.byte  %11111000,%00001000,%00010000,%00100000,%01000000,%10000000,%11111000 ;Z
_NUMBERS:
	;; digits
	.byte  %01110000,%10001000,%10001000,%10101000,%10001000,%10001000,%01110000
	.byte  %00100000,%01100000,%10100000,%00100000,%00100000,%00100000,%11111000
	.byte  %11110000,%00001000,%00001000,%00110000,%11000000,%10000000,%11111000
	.byte  %11110000,%00001000,%00001000,%01110000,%00001000,%00001000,%11110000
	.byte  %00010000,%00110000,%01010000,%10010000,%11111000,%00010000,%00010000

	.byte  %11111000,%10000000,%11100000,%00010000,%00001000,%00010000,%11100000

	.byte  %00110000
            .byte  %01000000
	.byte  %10000000
            .byte  %11110000
	.byte  %10001000
            .byte  %10001000
	.byte  %01110000

	.byte  %11111000,%00001000,%00010000,%00100000,%01000000,%01000000,%01000000
	.byte  %01110000,%10001000,%10001000,%01110000,%10001000,%10001000,%01110000
	.byte  %01110000,%10001000,%10001000,%01111000,%00001000,%00010000,%01100000
	.byte  %00100000,%01010000,%10001000,%11111000,%10001000,%10001000,%10001000 ;A
	.byte  %11110000,%10001000,%10001000,%11110000,%10001000,%10001000,%11110000 ;B
	.byte  %01110000,%10001000,%10000000,%10000000,%10000000,%10001000,%01110000 ;C
	.byte  %11100000,%10010000,%10001000,%10001000,%10001000,%10010000,%11100000 ;D
	.byte  %11111000,%10000000,%10000000,%11100000,%10000000,%10000000,%11111000 ;E
	.byte  %11111000,%10000000,%10000000,%11100000,%10000000,%10000000,%10000000 ;F
_SYMBOLS:
            ;; ':','$',','
	.byte  %00000000
            .byte  %00000000
	.byte  %00010000
            .byte  %00000000
	.byte  %00000000
            .byte  %00010000
	.byte  %00000000

            .byte  %00100000
	.byte  %01110000
            .byte  %01000000
	.byte  %01110000
            .byte  %00010000
	.byte  %01110000
            .byte  %00100000

            .byte  %00000000
	.byte  %00000000
            .byte  %00000000
	.byte  %00000000
            .byte  %00000000
	.byte  %00100000
            .byte  %01000000
