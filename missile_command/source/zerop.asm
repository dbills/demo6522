.include "screen.inc"
.include "zerop.mac"
.exportzp ptr_0, ptr_1, ptr_2, ptr_3, pltbl, pltbl_end, save_y, ptr_string, sleep_t
.exportzp debugb,ptr_4,sp_col0,sp_col1,sp_col2,frame_cnt, scratch1, zb_icbm
.exportzp zp_cnt1,zp_cnt2,zp_cnt3,zp_lvl,zp_3cnt
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
pltbl_end = * - 1
sp_col0:                                ;sprite screen column 0
ptr_0:      .res 2                      ;plot used
sp_col1:                                ;sprite screen column 1
ptr_1:      .res 2
ptr_2:      .res 2                      ;sp_draw
ptr_3:      .res 2                      ;sprite
save_y:     .res 1
sleep_t:    .res 1
debugb:     .res 1
s_src:      .res 1
;;; mysterious padding
;;; because something is
;;; attacking zero page?
;unused:     .res 3
ptr_string: .res 2
sp_col2:                                ;sprite screen column 2
ptr_4:      .res 2
frame_cnt:  .res 1
zp_cnt1:    .res 1                      ;16bit frame counter low
zp_cnt2:    .res 1                      ;16bit frame counter high
zp_cnt3:    .res 1                      ;3 bit counter ( 0-7 )
zp_3cnt:    .res 1                      ;0-3 counter
zp_lvl:     .res 1                      ;game level
scratch1:   .res 1
zb_icbm:    .res 1                      ; icbm iterator
.CODE
