          SEG ZEROP
LASTJOY   dc.b
          SEG CODE
i_joy     subroutine
          lda #127
          sta VIA2DDR             ;setup VIA for joystick read

          lda #0
          sta $9113               ;joy VIA to input
          rts

;;; waits for joystick to be pressed
;;; and released
j_wfire   subroutine
.loop
          lda JOY0                ;read joy register
          and #JOYT               ;was trigger pressed?
          bne .loop
.loop1                            ;wait trigger release
          lda JOY0
          and #JOYT
          bne .fire
          beq .loop1
.fire
          rts

;;; read joystick value into single byte
;;; requires multiple VIA read due to vic20 design
j_read    subroutine
          lda JOY0
          and #$7f                ;clear bit 7 ( joy right )
          sta LASTJOY
          lda JOY0B
          and #JOYR
          ora LASTJOY             ;or in bit 7 as jstick right bit
          rts
          
