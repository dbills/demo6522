.include "zerop.inc"
.include "m16.mac"
.include "screen.mac"
.include "system.mac"
.include "colors.equ"
.zeropage
_pl_x:      .res 1
_pl_y:      .res 1
.CODE
.export _plot,i_pltbl,BMASKS,abort,i_pltbl,i_hires,i_chrset
.exportzp _pl_x,_pl_y
.proc abort
.endproc
;;; initialize the plot table
;;; ram starting location for all hires
;;; screen columns
.proc     i_pltbl
          ldy #SCADDR_SZ - 1
          mov #SCADDR, ptr_0
loop:
          lda (ptr_0),y
          sta pltbl,y
          dey
          bpl loop
          rts
.endproc

.proc     _plot
          plotm lda _pl_x
          rts
.endproc

;;; fill screen with a tiled
;;; set of chars to allow bitmapped
;;; graphics
.proc     i_hires
          chbase CHBASE1
          setrows SCRROWS
          setcolumns SCRCOLS
          setleft 3
          tallchar
          ldy SCRMAP_SZ
          ;; fill screen with chars tile
          ;; pattern
loop:
          lda #YELLOW
          sta CLRRAM-1,y
          lda SCRMAP-1,y
          sta SCREEN-1,y
          dey
          bne loop
          rts
.endproc
;;; clear ram allocated to custom
;;; character set
.proc     i_chrset
          mov #CHBASE1, ptr_0
          ldy #0
          ldx #16                       ;# of pages
          lda #0                        ;AA is nice
loop:
          sta (ptr_0),y
          iny
          beq inch
          bne loop
inch:
          inc ptr_0 + 1
          dex
          beq done
          bne loop
done:
          rts
.endproc

.DATA
SCADDR:
;;; screen column addresses for chargen ram
;;; on the hi-res screen
;;; column 0 would be start in chram for 'A'
;;; column 1 would be start in chram for letter 'A' + SCRROWS
;;; etc.
COL       .set 0
          .repeat SCRCOLS
          .word CHBASE1 + (COL * SCRROWS * CHARHT)
COL       .set COL + 1
          .endrep
SCADDR_SZ = * - SCADDR
;;; predefined bytes for each of the 8
;;; possible bit positions, starting with
;;; bit 7 -> bit 0 on
;;; for dy>dx line drawing
BMASKS:
BPOS      .set 128
          .repeat 8
          .byte BPOS
BPOS      .set BPOS >> 1
          .endrep
;;; the character tiles in screen memory
;;; that comprise the hi-res screen
;;; as vertical strips i.e.
;;; the first strip would be:
;;; column 0123456 ...
;;;        ----------------------------
;;;        ADG
;;;        BEH
;;;        CFI
;;; etc ...
;;; except the height is 11 and not 3 in the
;;; example
_SCRMAP:
SCRMAP:
ROW       .set 0
          .repeat SCRROWS
COL       .set 0
            .repeat SCRCOLS
            .byte ROW + COL * SCRROWS
COL         .set COL + 1
            .endrep
ROW       .set ROW + 1
          .endrep
SCRMAP_SZ:
          .byte * - SCRMAP
.export SCADDR,SCRMAP,_SCRMAP,SCRMAP_SZ
