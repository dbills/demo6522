.include "screen.inc"
.include "zerop.mac"
.exportzp ptr_0,ptr_1,ptr_2,ptr_3,pltbl,save_y,_pl_x,_pl_y,s_x,s_y
;;; place me last in the 'main' includes
;;; I allocate space for arrays allocated in zp
;;; using variables that subsytem modules may have incremented
;;; pltbl: table of CHRAM columns
;;; 0 = address of CHRAM for column 0
;;; 2 = address of CHRAM for column 1
;;; ... up to SCRCOLS defined in screen.equ
.ZEROPAGE
pltbl:      .REPEAT SCRCOLS
            .res 2
            .ENDREPEAT
ptr_0:      .res 2                        ;plot used
ptr_1:      .res 2
ptr_2:      .res 2                        ;sp_draw
ptr_3:      .res 2
save_y:     .res 1
save_x:     .res 1
last_x:     .res 1
;;; 3 sprite objects
s_x:        .res 3
s_y:        .res 3
s_src:      .res 3
;;; end sprite object
_pl_x:      .res 1
_pl_y:      .res 1
LASTJOY:    .res 1
.CODE
