          processor 6502

          include   "screen.mac"
          include   "zerop.equ"         ;must be near top
          include   "timer.mac"
          include   "m16.mac"
          include   "colors.equ"
          include   "line.equ"
          include   "math.mac"
          include   "system.equ"
          include   "jstick.mac"
          include   "kplane.mac"

          SEG       CODE
          org $3000

          ;; enabling interrupts really pisses the system off with 
          ;; the scren and character configs I have
          mov_wi MINISR, $0314
          ;mov_wi DEFISR, $0314          ;
          cli

          jsr i_pltbl           
          jsr i_hires
          jsr i_chrset
          jsr i_joy
          chbase %1100                  ;$1000
          screenmem $0200
          ;; border colors
          lda $900f
          ora #2
          sta $900f
          ;jsr rotate1

          jsr bounce
          jmp loop
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

;;; wait vertical blank
wait_v    subroutine
.iloop
          lda VICRASTER           ;load raster line
          bne .iloop
          rts

bounce    subroutine
.reset
          lda #SCRROWS*16-8
          sta s_y
          lda #160
          sta s_x
          ldx #S_TARGET
          jsr sp_draw
.loop
          jsr wait_v
          ldx #S_TARGET
          jsr sp_draw                   ;erase

          ldx #S_TARGET
          jsr moveme

          ldx #S_TARGET
          jsr sp_draw                   ;draw

          jmp .loop
          rts



i_intr    subroutine
          sei
          lda $bf                       ;eabf
          sta $0314
          lda $ea
          sta $0315
          cli
          rts

;;; mindless bit pattern to check
;;; interrupt service routines
rotate1   subroutine
.doom
          lda $a2
          sta $1000
          lda fubar
          sta $1001
          inc fubar
          jmp .doom
fubar    dc.b
          rts


          include "screen.asm"
          include "timer.asm"
          include "line.asm"
          include "sprite.asm"
          include "jstick.asm"
          include "target.asm"
          include "zerop.asm"           ;must be last
          include "screen.dat"
          include "shapes.dat"
          include "line.dat"

ldata1  
