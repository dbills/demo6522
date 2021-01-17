.include "system.inc"
.export sound_interrupt,test_sound,sound_init,missile_away
MISSILE_DELAY = 6
.zeropage
.data
i_missile_sound:    .byte table_end - missile_away_table
missile_delay:      .res 1
.code

.proc     sound_interrupt
          sei
          lda i_missile_sound
          cmp #table_end - missile_away_table
          beq done

          tax
          lda missile_away_table,x
          sta 36877
          inx
          stx i_missile_sound
          jmp MINISR
done:
          lda #0
          sta 36877
          jmp MINISR
.endproc

.proc     missile_away
          lda #MISSILE_DELAY
          sta missile_delay
          lda #0
          sta i_missile_sound
          rts
.endproc

.proc     sound_init
          lda #table_end - missile_away_table
          sta i_missile_sound
          rts
.endproc

.proc     test_sound
loop:
          jsr tmissile_away
          ldx #60
delay:
          waitv
          dex
          bne delay
          jmp loop
          rts
.endproc
.proc     tmissile_away
          ldx #0

loop:

          sleep 6
          lda missile_away_table,x
          sta 36877
          inx
          cpx #table_end - missile_away_table
          bne loop
          rts
.endproc

.data
missile_away_table:
.byte 250
.byte 250
.byte 250
.byte 250
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 249
.byte 248
.byte 248
.byte 248
.byte 248
.byte 248
.byte 248
.byte 248
.byte 248
.byte 248
.byte 248
.byte 247
.byte 247
.byte 247
.byte 247
.byte 247
.byte 247
.byte 247
.byte 246
.byte 246
.byte 246
.byte 246
.byte 246
.byte 246
.byte 245
.byte 245
.byte 245
.byte 245
.byte 245
.byte 244
.byte 244
.byte 244
.byte 244
.byte 244
.byte 243
.byte 243
.byte 243
.byte 243
.byte 242
.byte 242
.byte 242
.byte 242
.byte 241
.byte 241
.byte 241
.byte 241
.byte 240
.byte 240
.byte 240
.byte 240
.byte 239
.byte 239
.byte 239
.byte 238
.byte 238
.byte 238
.byte 237
.byte 237
.byte 237
.byte 237
.byte 236
.byte 236
.byte 236
.byte 235
.byte 235
.byte 235
.byte 234
.byte 234
.byte 233
.byte 233
.byte 233
.byte 232
.byte 232
.byte 232
.byte 231
.byte 231
.byte 230
.byte 230
.byte 230
.byte 229
.byte 229
.byte 228
.byte 228
.byte 228
.byte 227
.byte 227
.byte 226
.byte 226
.byte 226
.byte 225
.byte 225
.byte 224
.byte 224
.byte 223
.byte 223
.byte 222
.byte 222
.byte 221
.byte 221
.byte 220
.byte 220
.byte 219
.byte 219
.byte 219
.byte 218
.byte 217
.byte 217
.byte 216
.byte 216
.byte 215
.byte 215
.byte 214
.byte 214
.byte 213
.byte 213
.byte 212
.byte 212
.byte 211
.byte 211
.byte 210
.byte 209
table_end:
