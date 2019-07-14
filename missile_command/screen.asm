;;; initialize the plot table
;;; ram starting location for all hires
;;; screen columns
          seg       ZEROP
.blargo    dc.b 0          
          seg       CODE
          lda .blargo
i_pltbl   subroutine
          ldy #SCADDR_SZ - 1
          mov_wi SCADDR, ptr_0
.loop
          lda (ptr_0),y
          sta pltbl,y
          dey
          bpl .loop
          rts
;;; pl_x, pl_y
;;; a = color
plot      subroutine
          ;; grab X % 8 for
          ;; bit offset in byte
          lda #%00000111
          and pl_x
          tay
          ldx BMASKS,y          ;y=bitmask
          lda pl_x
          ;; divide by 8
          ;; to get screen character column
          lsr
          lsr
          lsr
          ;; multiply by 2 to get zp address
          ;; of screen column CHRAM ptr
          ;; and place in Y
          asl
          tay
          ;; copy correct ptr to ptr_0
          lda pltbl,y
          sta ptr_0
          iny
          lda pltbl,y
          sta ptr_0 + 1
          ;; ptr_0 is location in CHRAM
          ;; of the correct character column
          txa                   ;bitmask to A
          ldy pl_y
          eor (ptr_0),y
          sta (ptr_0),y
          

          rts
