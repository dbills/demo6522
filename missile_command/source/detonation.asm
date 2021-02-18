;;; missile detonations
.include "zerop.inc"
.include "screen_draw.inc"
.include "sprite.inc"
.include "m16.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "shapes.mac"
.export queue_detonation, i_detonation, test_detonation, draw_detonations, update_detonations

spackle1 = %10101010
spackle2 = %01010101

.linecont
.data
;;; this is a table of tables
;;; each entry in here is a pointer to a table of pointers
;;; e.g. draw_explosion_2_table - is the list of function
;;; pointers for drawing all preshifted images for explosion
;;; of radius = 2
explosion_drawtable_by_offset_table:
.word \
             draw_explosion_R_0_table \
            ,draw_explosion_R_1_table \
            ,draw_explosion_R_2_table \
            ,draw_explosion_R_3_table \
            ,draw_explosion_R_4_table \
            ,draw_explosion_R_5_table \
            ,draw_explosion_R_6_table \
            ,draw_explosion_R_7_table
;;; which frame to show, and it what order
explosion_frame_table:
            .byte 1,2,3,4,5,6,7,6,5,4,3,2,1,0
sz_explosion_frame_table = (* - explosion_frame_table)
.macro explosion_y_offset_from_frame frame
            7 - frame
.endmacro
.bss
slots = 30
frame_delay = 20
detonation_table:   .word slots
detonation_proc:    .word slots
i_detonation_frame: .res slots
detonation_y:       .res slots          ;orig Y coor
detonation_cy:      .res slots          ;next Y draw
.export screen_column
screen_column:      .res slots
.code

.proc       i_detonation
            ldx #slots-1
            lda #255
loop:
            sta i_detonation_frame,x
            dex
            bpl loop
            rts
.endproc
;;;
.proc       queue_detonation
            ldx #slots-1
loop:
            lda i_detonation_frame,x
            bmi available
            dex
            bpl loop
            rts
available:
            lda _pl_x
            sec
            sbc #detonation_xoff
            tay                         ;save x coord
            calc_screen_column          ;x/8
            sta screen_column,x
            tya                         ;restore x coord
            and #7                      ;modulo8
            asl                         ;* 2
            tay
            ;; we have the bit offset, place the
            ;; table of explosion draw routines, for this
            ;; offset into the detonation_table for this
            ;; explosion
            lda explosion_drawtable_by_offset_table,y
            sta detonation_table,x
            lda explosion_drawtable_by_offset_table+1,y
            sta detonation_table+1,x
            lda _pl_y
            sec
            sbc #detonation_yoff
            sta detonation_y,x
            ;; initialize to just beyond end of table
            lda #sz_explosion_frame_table
            sta i_detonation_frame,x
            rts
.endproc

.proc       test_detonation
            lda #79
            sta _pl_x
            sta _pl_y
            jsr queue_detonation
loop:
            ldx #$1d
            jsr update_detonation
            ldx #$1d
            jsr draw_detonation
            jsr j_wfire
            jsr draw_detonation

            jmp loop
            rts
.endproc
.macro      setup_draw
            lda pltbl+0,y
            sta sp_col0
            lda pltbl+1,y
            sta sp_col0+1
            lda pltbl+2,y
            sta sp_col1
            lda pltbl+3,y
            sta sp_col1+1
            lda pltbl+4,y
            sta sp_col2
            lda pltbl+5,y
            sta sp_col2+1
.endmacro
;;; x = explosion to update
;;; frame = -1 not filled
.proc       update_detonation
            lda i_detonation_frame,x
            sec
            sbc #1
            bpl active
            sta i_detonation_frame,x
            rts
active:
            sta i_detonation_frame,x
            tay                         ;index into explosion_frame_table
            lda #7                      ;7-frame
            sec
            sbc explosion_frame_table,y
            sta detonation_cy,x
            ;; calculate the current Y coordinate to draw at
            ;; it's differenct for every frame, as frame are different
            ;; heights
            lda detonation_y,x
            clc
            adc detonation_cy,x
            sta detonation_cy,x
            ;; for each frame, there is a rendering/drawing functions
            ;; ptr_0 = detonation_table[x]
            lda detonation_table,x
            sta ptr_0
            lda detonation_table+1,x
            sta ptr_0+1
            ;;
            ;; detonation_proc[x] = detonation_table[explosion_frame]
            lda explosion_frame_table,y
            asl                         ;*2 to access table of words
            tay
            lda (ptr_0),y
            sta detonation_proc,x
            iny
            lda (ptr_0),y
            sta detonation_proc+1,x
            rts
.endproc
;;; x = explosion to draw
.proc       draw_detonation
jmp_operand = jmp0 + 1
            lda detonation_proc,x
            sta jmp_operand
            lda detonation_proc+1,x
            sta jmp_operand+1
            ldy screen_column,x
            setup_draw
            ldy detonation_cy,x
jmp0:
            jmp 0                       ;dynamic operand
.endproc

.macro      iterate_detonations routine
            .local loop,next,done
            ldx #slots-1
loop:
            txa
            ;; draw when frame_cnt match X index
            eor frame_cnt
            bne next
            routine
next:
            dex
            bpl loop
done:
            rts
.endmacro

.proc       update_detonations
            iterate_detonations jsr update_detonations
            rts
.endproc

.proc       draw_detonations
            iterate_detonations jsr draw_detonations
            rts
.endproc

.zeropage
drawit_savex:           .res 1
.code

.proc       drawit2
            rts
.endproc
