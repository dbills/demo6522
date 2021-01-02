;;; routines for maintaining an invisible text debugging screen
;;; that may be swapped in when needed
.include "debugscreen.mac"
.include "screen.inc"
.include "zerop.inc"
.include "m16.mac"
;.include "system.mac"
.export i_debug_screen,show_debug_screen, _debug_screen_write_char, _debug_screen_write_byte, _debug_screen_write_digit
.bss
z_save:   .res 1
.code
;;; set screen back to normal
;;; text mode
.proc     show_debug_screen
          shortchar
          ;; reset chargen to ROM
          chbase $8000
          ;; reset screen
          mov #SCREEN, ptr_0
          mov #DEBUG_SCREEN, ptr_1
          ldy #0
loop:
          lda(ptr_1),y
          sta(ptr_0),y
          incw ptr_0
          incw ptr_1
          cmpw #DEBUG_SCREEN_END,ptr_1
          bne loop
          rts
.endproc

.proc     i_debug_screen
          mov #DEBUG_SCREEN, ptr_1
          ldy #0
loop:
          lda #'z'
          sta (ptr_1),y
          incw ptr_1
          cmpw #DEBUG_SCREEN_END,ptr_1
          bne loop
          rts
.endproc

.proc     scroll_debug_screen
          mov #DEBUG_SCREEN, ptr_0
loop:
          cmpw #DEBUG_SCREEN_END,ptr_0
          beq done
          ldy #1
          lda(ptr_0),y
          dey
          sta(ptr_0),y
          incw ptr_0
          jmp loop
done:
          lda #32                       ;space
          sta(ptr_0),y
          rts
.endproc

;;; write to the invisible debug text screen
;;; which is normal VIC text
;;; IN: A = char
.proc     _debug_screen_write_char
          sta DEBUG_SCREEN_END-1
          jsr scroll_debug_screen
          rts
.endproc
.proc     _debug_screen_write_digit
          cmp #9
          bcc is_not_letter
          sec
          sbc #9
          jsr _debug_screen_write_char
          jmp done
is_not_letter:
          clc
          adc #48
          jsr _debug_screen_write_char
done:
          rts
.endproc
.proc     _debug_screen_write_byte
          pha
          and #$f0
          lsr
          lsr
          lsr
          lsr
          jsr _debug_screen_write_digit
          pla
          and #$0f
          jsr _debug_screen_write_digit
          rts
.endproc
