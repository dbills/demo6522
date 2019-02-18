          processor 6502

          include   "screen.mac"
          include   "timer.mac"
          include   "zerop.equ"
          include   "m16.mac"
          include   "colors.equ"

          SEG       MAIN
          org $3000

          jsr i_pltbl           
          jsr i_hires
          jsr i_chrset
          chbase %1100
          screenmem $0200
          lda $900f
          ora #2
          sta $900f
          lda #0
          sta pl_y
          sta pl_x
l1
          jsr plot
          inc pl_x
          inc pl_y
          lda #172
          cmp pl_x
          beq loop
          jmp l1
          

loop
          jmp loop
          rts



i_hires   subroutine
          setrows
          tallchar              
          ldy #SCRMAP_SZ
          ;; fill screen with chars tile
          ;; pattern 
.loop
          lda #BLUE
          sta CLRRAM-1,y
          lda SCRMAP-1,y
          sta SCREEN-1,y
          dey
          bne .loop
.done
          rts

          
i_chrset  subroutine
          mov_wi CHBASE1, ptr_0
          ldy #0
          ldx #16               ;# of pages
          lda #0                ;AA is nice
.loop
          sta (ptr_0),y
          iny
          beq .inch
          bne .loop
.inch
          inc ptr_0 + 1
          dex
          beq .done
          bne .loop
.done
          rts

          include "screen.asm"
          include "timer.asm"
          ;;include "line.asm"
          include "screen.dat"
