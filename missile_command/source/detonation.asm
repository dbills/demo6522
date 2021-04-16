;;; missile detonations
.include "zerop.inc"
.include "screen_draw.inc"
.include "sprite.inc"
.include "m16.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "shapes.mac"
.export queue_detonation, i_detonation, test_detonation, draw_detonations, update_detonations,erase_detonations, rand_detonation

;;; i_detonation_frame = -1 => don't draw, but erase
;;;                    = -2 => don't draw or erase
;;; or, put another way:
;;; Let A = i_frame, B = i_frame2
;;;  0  1  =>  -1  0  =>  -2  -1
;;;  A  B       A  B       A   B
;;; ----------------------------
;;;   T0         T1          T2
;;;
;;; T0 = drawing the last frame of an animation
;;; T1 = drawing nothing, but erasing the last frame
;;; T2 = drawing nothing, erasing nothing
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
            .byte 0,1,2,3,4,5,6,7,6,5,4,3,2,1
;            .byte 7,2
sz_explosion_frame_table = (* - explosion_frame_table)
.macro explosion_y_offset_from_frame frame
            7 - frame
.endmacro
.bss
slots = 20
;;; pointer to the list of rendering routines for this detonation
;;; there is a set of routines for each possible preshifted bit
;;; pattern of detonation
;;; e.g. if we are drawing at screen X = 1
;;; then we need the preshifted=1 set of drawing routines
;;; and detonation_table is what points to those
detonation_tableL:   .res slots
detonation_tableH:   .res slots
;;; the current rendering routine based on preshift and animation frame
detonation_procL:    .res slots
detonation_procH:    .res slots
detonation_proc2L:    .res slots
detonation_proc2H:    .res slots
;;; when frame is < 0, then this detonation is not active
i_detonation_frame: .res slots
i_detonation_frame2: .res slots
;;; Y coordinate of center of explosion
detonation_y:       .res slots
;;; Y coordinate to render the current frame at, taking
;;; into account the individual frame's offset
detonation_cy:      .res slots
detonation_cy2:      .res slots
.export screen_column
screen_column:      .res slots
.code

.proc       i_detonation
            ldx #slots-1
loop:
            ;; load -2, implies no draw, no erase
            lda #$fe                    ;-2
            sta i_detonation_frame,x
            ;; load -1, implies no erase
            lda #$ff                    ;-1
            sta i_detonation_frame2,x
            dex
            bpl loop
            rts
.endproc
;;;
.proc       queue_detonation
            ldx #slots-1
loop:
            lda i_detonation_frame,x
            cmp #$fe
            beq available
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
            sta detonation_tableL,x
            lda explosion_drawtable_by_offset_table+1,y
            sta detonation_tableH,x
            lda _pl_y
            sec
            sbc #detonation_yoff
            sta detonation_y,x
            ;; initialize to just beyond end of table
            lda #sz_explosion_frame_table-1
            sta i_detonation_frame,x
            jsr update_detonation_data
            lda #$ff                    ;-1
            sta i_detonation_frame2,x
            rts
.endproc
rmax = YMAX-32
.proc       myrand
            jsr rand_8
check:
            cmp #rmax
            bcc done
            sec
            sbc #rmax
            jmp check
done:
            clc
            adc #8
            rts
.endproc

.proc       rand_detonation
            jsr myrand
            sta _pl_x
            jsr myrand
            sta _pl_y
            jsr queue_detonation
            rts
.endproc
.data
fubar:      .res 1
.code
.import wait_v
.proc       test_detonation
loop:
            jsr rand_8
            and #7
            bne skip
            jsr rand_detonation
skip:
            jsr wait_v
            update_frame

            ;jsr j_wfire
            ldx #(slots-1)
            jsr erase_detonations

            ;jsr j_wfire
            ldx #(slots-1)
            jsr draw_detonations

            ldx #(slots-1)
            jsr update_detonations
            jmp loop
            rts
.endproc
;;; load the screen and sprite
;;; pointer for a draw
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
;;; note: there is a sequence of animation 'frames' to
;;; show, that sequence is stored at explosion_frame_table
;;; after an explosion is erased
;;; i_detonation_frame = -2
;;; i_detonation_frame2 = -1
.proc       update_detonation
            lda i_detonation_frame,x
            cmp #$fe                     ;-2
            beq inactive
            ;; copy for double buffering
            sta i_detonation_frame2,x
            lda detonation_cy,x
            sta detonation_cy2,x
            lda detonation_procL,x
            sta detonation_proc2L,x
            lda detonation_procH,x
            sta detonation_proc2H,x

            dec i_detonation_frame,x
            bmi inactive
            jmp update_detonation_data
inactive:
            rts
.endproc
;;; in: A = detonation frame
;;;     X = detonation number
.proc       update_detonation_data
active:
            lda i_detonation_frame,x
            tay                         ;index into explosion_frame_table
            ;; animation frame offset: y=7-frame number
            lda #7
            sec
            sbc explosion_frame_table,y
            ;; calculate the current Y coordinate to draw at
            ;; it's differenct for every frame, as frame are different
            ;; heights
            clc
            adc detonation_y,x
            sta detonation_cy,x
            ;; for each frame, there is a rendering/drawing functions.
            ;; detonation_table points to the correct set of those functions
            ;; for our preshifted animation images.
            ;; ptr_0 = detonation_table[x]
            lda detonation_tableL,x
            sta ptr_0
            lda detonation_tableH,x
            sta ptr_0+1
            ;; detonation_proc[x] = detonation_table[explosion_frame]
            lda explosion_frame_table,y
            asl                         ;*2 to access table of words
            tay
            lda (ptr_0),y
            sta detonation_procL,x
            iny
            lda (ptr_0),y
            sta detonation_procH,x
            rts
.endproc
.proc       erase_detonation
jmp_operand = jmp0 + 1
            lda i_detonation_frame2,x
            bmi done
            lda detonation_proc2L,x
            sta jmp_operand
            lda detonation_proc2H,x
            sta jmp_operand+1
            ldy screen_column,x
            setup_draw
            ldy detonation_cy2,x
jmp0:
            jmp 0                       ;dynamic operand
done:
            rts
.endproc
;;; x = explosion to draw
.proc       draw_detonation
            lda i_detonation_frame,x
            bmi done
jmp_operand = jmp0 + 1
            lda detonation_procL,x
            sta jmp_operand
            lda detonation_procH,x
            sta jmp_operand+1
            ldy screen_column,x
            setup_draw
            ldy detonation_cy,x
jmp0:
            jmp 0                       ;dynamic operand
done:
            rts
.endproc

.macro      iterate_detonations routine
            .local loop,next,done
            ldx #slots-1
loop:
            txa
            and #7                      ;modulo 8
            cmp frame_cnt
            bne next
            routine
next:
            dex
            bpl loop
done:
            rts
.endmacro

.proc       update_detonations
            iterate_detonations jsr update_detonation
            rts
.endproc

.proc       erase_detonations
            iterate_detonations jsr erase_detonation
            rts
.endproc

.proc       draw_detonations
            iterate_detonations jsr draw_detonation
            rts
.endproc

.zeropage
drawit_savex:           .res 1
.code

.proc       drawit2
            rts
.endproc
