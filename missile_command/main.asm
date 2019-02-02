          processor 6502
          org $2000

          include   "macros16.asm"
          include   "zerop.asm"

SCREEN    equ       1000

          mac for
          mov_wi {1}, lpbeg_w
          mov_wi {2}, lpend_w
          endm

          mac next
          inc_w lpbeg_w
          cmp_w lpbeg_w, lpend_w
          beq .done
          jmp {1}
.done
          endm

i_hires   subroutine
          ;; activate 16 high chars
          lda #1
          and $9003
          sta $9003
          
          ldy #0
          ldx #0
          ;; fill screen with chars
          for SCREEN, mov_w 1,2


          
