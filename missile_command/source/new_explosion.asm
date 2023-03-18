.include "shape_draw.inc"
;; draw_explosion_7_shift7 = draw_explosion_6_shift7 
;; draw_explosion_7_shift6 = draw_explosion_6_shift6
;; draw_explosion_7_shift5 = draw_explosion_6_shift5
;; draw_explosion_7_shift4 = draw_explosion_6_shift4
;; draw_explosion_7_shift3 = draw_explosion_6_shift3
;; draw_explosion_7_shift2 = draw_explosion_6_shift2
;; draw_explosion_7_shift1 = draw_explosion_6_shift1
;; draw_explosion_7_shift0 = draw_explosion_6_shift0

;;; table of function pointers to
;;; draw explosions of preshift 0
;;; for each available radius
.export draw_explosion_R_0_table
draw_explosion_R_0_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift0", WIDTH))
.endrepeat
;;; table of function pointers to
;;; draw explosions of preshift 1
;;; for each available radius
.export draw_explosion_R_1_table
draw_explosion_R_1_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift1", WIDTH))
.endrepeat
;;; table of function pointers to
;;; draw explosions of preshift 2
;;; for each available radius
.export draw_explosion_R_2_table
draw_explosion_R_2_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift2", WIDTH))
.endrepeat
;;; table of function pointers to
;;; draw explosions of preshift 3
;;; for each available radius
.export draw_explosion_R_3_table
draw_explosion_R_3_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift3", WIDTH))
.endrepeat
;;; table of function pointers to
;;; draw explosions of preshift 4
;;; for each available radius
.export draw_explosion_R_4_table
draw_explosion_R_4_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift4", WIDTH))
.endrepeat
;;; table of function pointers to
;;; draw explosions of preshift 5
;;; for each available radius
.export draw_explosion_R_5_table
draw_explosion_R_5_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift5", WIDTH))
.endrepeat
;;; table of function pointers to
;;; draw explosions of preshift 6
;;; for each available radius
.export draw_explosion_R_6_table
draw_explosion_R_6_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift6", WIDTH))
.endrepeat
;;; table of function pointers to
;;; draw explosions of preshift 7
;;; for each available radius
.export draw_explosion_R_7_table
draw_explosion_R_7_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift7", WIDTH))
.endrepeat
;;; a pointer index table for the previous tables
;;; e.g. void *pointer = collision_table[x]
;;; where X would be one of the 8 possible explosion frame
;;; widths.  
collision_tableL:
.export collision_tableL
     .byte <collision_draw_explosion_0_shift0
     .byte <collision_draw_explosion_1_shift0
     .byte <collision_draw_explosion_2_shift0
     .byte <collision_draw_explosion_3_shift0
     .byte <collision_draw_explosion_4_shift0
     .byte <collision_draw_explosion_5_shift0
     .byte <collision_draw_explosion_6_shift0
     .byte <collision_draw_explosion_7_shift0
collision_tableR:
.export collision_tableR
     .byte >collision_draw_explosion_0_shift0
     .byte >collision_draw_explosion_1_shift0
     .byte >collision_draw_explosion_2_shift0
     .byte >collision_draw_explosion_3_shift0
     .byte >collision_draw_explosion_4_shift0
     .byte >collision_draw_explosion_5_shift0
     .byte >collision_draw_explosion_6_shift0
     .byte >collision_draw_explosion_7_shift0
