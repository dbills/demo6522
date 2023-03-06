.include "system.inc"
.include "screen.inc"
.include "jstick.inc"
.export so_isr, test_sound, so_init, so_missile, so_i_empty

.bss

i_missile_sound:    .res 1
so_i_empty:         .res 1

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
_2:       
          ldx so_i_empty
          dex
          stx so_i_empty
          bne done
          stx 36876                     ;voice off
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
          lda #8                        ;volume
          sta 36878

          rts
.endproc

;;; Test sound routines
;;; IN:
;;; OUT:
.proc     test_sound
loop:
          jsr so_missile

          jsr j_wfire
          jmp loop
          rts
.endproc

