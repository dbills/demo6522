.include "system.inc"
.include "screen.inc"
.include "jstick.inc"
.include "sound.mac"
.export so_isr, so_test, so_init, so_missile, so_i_empty, so_bomber_note

.bss

i_missile_sound:    .res 1
so_i_empty:         .res 1
so_bomber_note:     .res 1
.data
missile_away_table:
.byte 200
.byte 200
.byte 200
.byte 200
.byte 200
.byte 200
.byte 200
.byte 201
.byte 201
.byte 201
.byte 202
.byte 202
.byte 203
.byte 203
.byte 204
.byte 205
.byte 206
.byte 206
.byte 207
.byte 208
.byte 209
.byte 210
.byte 211
.byte 212
.byte 213
.byte 215
.byte 216
.byte 217
.byte 218
.byte 220
.byte 221
.byte 223
.byte 224
.byte 226
.byte 228
.byte 229
.byte 231
.byte 233
.byte 235
table_sz = * - missile_away_table

.code

;;; Sound interupt service routine
;;; IN:
;;; OUT:
;;;   all sound table indicies updated
.proc     so_isr
          sei
          ;; run interceptor sounds
          ldx i_missile_sound
          bne _1
          ;; turn it off
          ;sc_bcolor PURPLE
          lda #0
          sta 36877
          jmp _2
_1:                                     ; missile sound on
          lda missile_away_table,x
          sta 36877
          ;sc_bcolor BLUE
          dex
          stx i_missile_sound
_2:                                     ;missile's empty sound countdown
          ldx so_i_empty
          dex
          stx so_i_empty
          bne _3
          stx 36876                     ;voice off
          ;; bomber sound effect
_3:       
          lda so_bomber_note
          beq _4
          cmp #240                      ;non-inclusive upper bound
          bne note_in_sequence
          ;; note is at end of sequence, reset to beginngin
          lda #SO_BOMBER_START
          ;; note is in the sequence
note_in_sequence:
          ;; store bomber note in voice
          sta 36875
          clc
          adc #3
          sta so_bomber_note
_4:       
done:     
          jmp MINISR
.endproc

.proc     so_missile
          lda #table_sz
          sta i_missile_sound
          rts
.endproc

;;; Init sound system
;;; IN:
;;; OUT:
.proc     so_init
          lda #0                        ;quiet voice
          sta 36874
          sta 36875
          sta 36876
          sta 36877
          sta so_i_empty                ;empty sound off
          sta i_missile_sound           ;missile sound off
          sta so_bomber_note            ;bomber sound effect off
          lda #8                        ;volume
          sta 36878

          rts
.endproc

;;; Test sound routines
;;; IN:
;;; OUT:
.proc     so_test

          so_bomber_out

forever:   
          jmp forever
loop:
          jsr so_missile

          jsr j_wfire
          jmp loop

          rts
.endproc

