;;; code for managing interceptor missiles
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "sound.inc"
.include "sprite.inc"
.include "shapes.inc"
.include "system.mac"
.include "insertion_sort.inc"
.include "text.inc"
.include "debugscreen.inc"

.export i_interceptor,in_launch,update_interceptors


base_x = XMAX/2
base_y = YMAX-16

.code
.linecont

.proc     i_interceptor
          ldx #MAX_LINES-1
          lda #0
loop:
          sta line_data_indices,x
          dex
          bpl loop
          rts
.endproc


;;; launch an interceptor from the missile base
;;; to the players current crosshair location
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.data
;;; put a counter in
.code
.proc     in_launch
          lda #crosshair_xoff
          clc
          adc target_x
          sta _x2
          lda #crosshair_yoff
          clc
          adc target_y
          sta _y2
          ;; do we have interceptors left to launch?
          ;; TODO
          ;; bne ok
          ;; jmp empty
ok:
          ;; find an open missile slot
          ldx #MAX_MISSILES - 1
loop:     
          lda line_data_indices
          bne next                      ;slot if full
          ;; slot is open
          set_lstore
          lineto #base_x,#base_y,_x2,_y2
          jsr snd_missile_away
          rts
next:     
          dex
          bpl loop
empty:
          snd_missile_empty
          rts
.endproc
.importzp _pl_x,_pl_y
.include "detonation.inc"
;;; erase crosshair centered at pl_x,pl_y
;;; sprites are drawn  from the upper left
;;; so we need to derive upper left coord
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

;;; draw player inteceptors on the screen
;;; when an interceptor has reached its destination
;;; an explosion drawing is started and the missile line
;;; is removed
;;; 
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.bss
sort_index:         .res 1
.code
.proc     update_interceptors
          ldx #MAX_MISSILES - 1
loop:     
          lda line_data_indices
          beq  next                     ;inactive
          set_lstore
          jsr render_single_pixel
          beq erase
          ;; jsr render_single_pixel
          ;; beq erase
          ;; if Z on return the line is done
next:     
          dex
          bpl loop
          rts
erase:    
          ;; erase the line because we've reached our target
          jsr _general_render
          lda #0
          sta line_data_indices,x
          ;; queue an explosion
          jsr erase_crosshair_mark
          jsr queue_detonation
          rts

.endproc
