;;; initialize the plot table
;;; ram starting location for all hires
;;; screen columns
i_pltbl   subroutine
          lda #SCADDR_SZ - 1
          tay
          mov_wi SCADDR, ptr_0
.loop
          lda (ptr_0),y
          sta 0,y
          dey
          bpl .loop
          rts
