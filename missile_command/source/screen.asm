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

plot      subroutine
          plotm lda pl_x
          rts

