.export i_joy, j_wfire,  j_tup, j_read,LASTJOY
.include "jstick.mac"
.include "system.mac"
          .ZEROPAGE
LASTJOY:  .res 1
          .CODE
.proc     i_joy
          lda #127
          sta VIA2DDR             ;setup VIA for joystick read

          lda #0
          sta $9113               ;joy VIA to input
          rts
.endproc
;;; waits for joystick to be pressed
;;; and released
.proc     j_wfire
loop:
          jsr j_read
          cmp #JOYT
          beq fire
          jmp loop
fire:
          jsr j_tup
          rts
.endproc
;;; wait for trigger up
.proc     j_tup                   ; trigger up
loop1:
          lda JOY0
          and #bJOYT
          bne fire
          beq loop1
fire:
          rts
.endproc
;;; read joystick value into single byte
;;; requires multiple VIA read due to vic20 design
;;; OUT: A=LASTJOY=joystick value
;;; joystick bits are clear when the direction
;;; is pressed
;;;
;;; 10011100
.proc     j_read
          lda JOY0
          and #%111100
          sta LASTJOY
          lda JOY0B
          and #$80
          ora LASTJOY             ;or in bit 7 as jstick right bit
          sta LASTJOY
          rts
.endproc
