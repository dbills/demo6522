;;; missile detonations
.include "zerop.inc"
.include "screen_draw.inc"
.include "sprite.inc"
.include "m16.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "shapes.mac"

.include "debugscreen.inc"
.include "text.inc"

.export queue_detonation, i_detonation, test_detonation, draw_detonations, update_detonations,erase_detonations, rand_detonation, process_detonations

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
detonation_proc2L:   .res slots
detonation_proc2H:   .res slots
;;; when frame is < 0, then this detonation is not active
i_detonation_frame:  .res slots
i_detonation_frame2: .res slots
;;; Y coordinate of center of explosion
detonation_y:        .res slots
;;; Y coordinate to render the current frame at, taking
;;; into account the individual frame's offset
detonation_cy:       .res slots
detonation_cy2:      .res slots
.export screen_column
screen_column:      .res slots
i_detonation_count: .res 1
.code

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

.proc     process_detonations
          ldx #(slots-1)
          jsr erase_detonations

          ldx #(slots-1)
          jsr draw_detonations

          ;; this section would not be time critical
          ;; ( when we get around to optimizing the main loop )

          ldx #(slots-1)
          ;; skip for now while we test collisions
          ;jsr update_detonations
          rts
.endproc
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
            inc i_detonation_count
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
            txa                         ;if index
            and #7                      ;modulo 8
            cmp frame_cnt               ;==0
            bne next                    ;then
            routine                     ;execute
next:
            dex
            bpl loop
done:
            rts
.endmacro

.proc       update_detonations
            lda #0
            sta i_detonation_count
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

.proc       drawit2
            rts
.endproc

.data
old_target:         .byte 0
fubar1:   .byte 0
once:     .byte 0
.code
.include "colors.equ"
;;; the once,none silliness is so
;;; we can erase the old text before drawing the new
;;; the text drawing routines use xor
;;; I also think printing spaces didn't work because we just += width
;;; or maybe it doesn't work even if you try to xor because 0 xor 1 is still 1
.macro debug_display screenx,screeny,mem
          pos screenx,screeny
          jsr clear_line
          lda mem
          sta fubar1
          myprintf "x:%d",fubar1
.endmacro

TEST_COLUMN = 10
;;; screen columns for detonations is the first column
;;; as a 16 pixel sprite, it occupies at most 3 columns
;;; we check if we are at x,x+1,x+2
;;; to know if we are potentially in a column of an explosion
;;; once that is know, we check Y coordinates
;;; the original coordinate of the interceptor detonation is known
;;; the bounding rectangle for the explosion lives at
;;; x-detonation_xoff,y-detonation_yoff
;;; once we've established the bounding of the detonation
;;; and we think we are in it, then we need to calculate
;;; our relative position within that box
;;; we can then look at the current 'sprite' that's being in
;;; that box and check for a 1 bit at the corresponding location
;;; for this test function we are using the target crosshair
;;; as a proxy for an icbm so I can test.  If that works then
;;; we will substitute an actual ICBM coord
.proc check_collision
          lda target_x                  ;/8
          calc_screen_column
          sta fubar1
          debug_display 0,40,fubar1
         lda i_detonation_frame,x
         cmp #$fe                     ;-2
         bne active

          rts
active:   
;          stx fubar1
          lda detonation_y,x
          sec
          sbc #detonation_yoff
          cmp target_y
          bcc below_top
          ;; icbm is before detonation box
          clearpos 0,48
          myprintf "ab"
          rts
below_top:          
          ;; calc bottom of bounding rect
          clc
          adc #detonation_yoff*2
          cmp target_y
          bcc below_bottom
          ;; 
          ;; in detonation bounding box
          ;; 
          clearpos 0,48
          myprintf "in"

          rts
below_bottom:       
          clearpos 0,48
          myprintf "be"
          ;; we are below the bounding box
          rts
.endproc
;;; detect collision between detonation and icbm
.export collisions
.proc collisions
          iterate_detonations jsr check_collision
          rts
.endproc
