.include "screen.inc"
.include "zerop.mac"
.exportzp ptr_0,ptr_1,ptr_2,ptr_3,pltbl,save_y,pl_x,pl_y,s_x,s_y
;;; place me last in the 'main' includes
;;; I allocate space for arrays allocated in zp
;;; using variables that subsytem modules may have incremented
;;; pltbl: table of CHRAM columns
;;; 0 = address of CHRAM for column 0
;;; 2 = address of CHRAM for column 1
;;; ... up to SCRCOLS defined in screen.equ
.ZEROPAGE
pltbl:      .REPEAT SCRCOLS
            .word 0
            .ENDREPEAT
ptr_0:      .word 0                        ;plot used
ptr_1:      .word 0
ptr_2:      .word 0                        ;sp_draw
ptr_3:      .word 0
save_y:     .byte 0
save_x:     .byte 0
last_x:     .byte 0
;;; 3 sprite objects
s_x:        .byte 0,0,0
s_y:        .byte 0,0,0
s_src:      .byte 0,0,0
;;; end sprite object
pl_x:       .byte 0
pl_y:       .byte 0
LASTJOY:    .byte 0

