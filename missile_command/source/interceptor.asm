;;; code for managing interceptor missiles
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "sound.inc"
.include "sprite.inc"
.include "shapes.inc"
.include "system.inc"
.include "text.inc"
.include "dbgscreen.inc"
.include "playfield.inc"
.include "detonation.inc"

.export in_init, in_launch, in_update, remove_routineL,remove_routineH, cw1_s, cw1_e
.importzp _pl_x,_pl_y

base_x = XMAX/2
base_y = YMAX-16

.bss
in_mcount:          .res 1
.data
;;; function for updating the missile base at center of screen
remove_routineL: 
.byte <(pl_m0),<(pl_m1),<(pl_m2),<(pl_m3),<(pl_m4),<(pl_m5),<(pl_m6),<(pl_m7)
.byte <(pl_m8),<(pl_m9)
remove_routineH: 
.byte >(pl_m0),>(pl_m1),>(pl_m2),>(pl_m3),>(pl_m4),>(pl_m5),>(pl_m6),>(pl_m7)
.byte >(pl_m8),>(pl_m9)
.code
.linecont
;;; Initialize and interceptor module
;;; IN:
;;; OUT:
cw1_s:    
.proc     in_init
          jsr in_reload
          ldx #MAX_MISSILES-1
          lda #0
loop:
          sta line_data_indices,x
          dex
          bpl loop
          rts
.endproc
;;; todo: reload missiles
.proc in_reload
          lda #10
          sta in_mcount
          rts
.endproc

.proc in_remove
          cpx #10
          bcc ok
          brk
ok:       
          sy_dynajump2 "remove_routine"
.endproc
cw1_e:    
;;; launch an interceptor from the missile base
;;; to the players current crosshair location
;;; IN:
;;;   target_x, target_y: crosshair location
;;; OUT:
.proc     in_launch
          lda #crosshair_xoff
          clc
          adc target_x
          sta z_x2
          lda #crosshair_yoff
          clc
          adc target_y
          sta z_y2

          ldx in_mcount
          beq empty
          dex
          stx in_mcount
          jsr in_remove
          ;; find an open missile slot
          ldx #MAX_MISSILES - 1
loop:     
          lda line_data_indices,x
          bne next                      ;slot is full
          ;; slot is open
          li_setz_lstore
          li_lineto #base_x, #base_y, z_x2, z_y2
          jsr so_missile
          rts
next:     
          dex
          bpl loop
          ;; can't fire anymore, but you are not empty
          rts
empty:
          so_empty
          rts
.endproc
;;; Erase crosshair centered at pl_x, pl_y
;;; sprites are drawn  from the upper left
;;; so we need to derive upper left coord
;;; to the players current crosshair location
;;; IN:
;;;   plx_x,pl_y: 
;;; OUT:
;;; 
.proc     erase_crosshair_mark
          lda target_x
          pha
          lda target_y
          pha

          lda _pl_x
          sec
          sbc #crosshair_xoff
          sta target_x
          lda _pl_y
          sec
          sbc #crosshair_yoff
          sta target_y
;          sp_draw crosshair, 5

          pla
          sta target_y
          pla
          sta target_x
          rts
.endproc

;;; Draw player inteceptors on the screen
;;; 
;;; when an interceptor has reached its destination an explosion drawing
;;; is started and the missile line is removed
;;; 
;;; IN:
;;; OUT:
.proc     in_update
          ldx #MAX_MISSILES - 1
loop:                                   ; do {
          lda line_data_indices,x
          beq  next                     ; inactive
          li_setz_lstore
          jsr li_render_pixel
          beq erase
next:     
          dex
          bpl loop                      ; } while x >= 0
          rts
erase:    
          ;; erase the line because we've reached our target
          jsr li_full_render
          lda #0
          sta line_data_indices,x
          ;; queue an explosion
          ;jsr erase_crosshair_mark
          jsr de_queue
          rts

.endproc
