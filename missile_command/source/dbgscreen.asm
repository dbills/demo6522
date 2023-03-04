;;; routines for maintaining an invisible text debugging screen
;;; that may be swapped in when needed
.include "dbgscreen.mac"
.include "screen.inc"
.include "zerop.inc"
.include "m16.mac"
.include "jstick.inc"

.export db_init,db_show, db_wchar, db_wbyte, db_whexchar, db_abort
.bss
z_save:   .res 1
.code
;;; set screen back to normal
;;; text mode
.proc     db_show
          sc_shortchar
          ;; reset chargen to ROM
          sc_chbase $8000
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

.proc     db_init
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

.proc     db_scroll
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
.proc     db_wchar
          sta DEBUG_SCREEN_END-1
          jsr db_scroll
          rts
.endproc
.proc     db_whexchar
          cmp #9
          bcc is_not_letter
          sec
          sbc #9
          jsr db_wchar
          jmp done
is_not_letter:
          clc
          adc #48
          jsr db_wchar
done:
          rts
.endproc
;;; Write byte to debug screen
;;; IN:
;;;   A: byte to write
;;; OUT:
.proc     db_wbyte
          pha
          and #$f0
          lsr
          lsr
          lsr
          lsr
          jsr db_whexchar
          pla
          and #$0f
          jsr db_whexchar
          rts
.endproc

.proc db_abort
loop:
          jsr j_wfire
          jsr db_show
          jsr j_wfire
          jsr sc_hires
          jmp loop
.endproc
