.include "zerop.inc"
.include "m16.mac"
.include "screen.mac"
.CODE
.export _plot,i_pltbl,BMASKS
;;; initialize the plot table
;;; ram starting location for all hires
;;; screen columns
.proc     i_pltbl
          ldy #SCADDR_SZ - 1
          movi SCADDR, ptr_0
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
;;;        Axy
;;;        Bxy
;;;        Cxy
;;; etc ...
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
