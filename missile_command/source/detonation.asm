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
;;; e.g. draw_explosion_2_table: the list of function
;;; pointers for drawing all preshifted images for explosion
;;; of radius = 2.  Each function in that table would correspond
;;; to a particular bitshift to the right: 0 <= bitshift < 16
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
;;; which frame to show, and in what order
;;; there are 8 explosion frames, for 8 different widths of the fireball
;;; this describes the animnation sequence then:
;;; start small fireball grow large, then shrink again
;;; the sequence is run from the end to the beginning for performance
explosion_frame_table:
;            .byte 0,1,2,3,4,5,6,7,6,5,4,3,2,1
            .byte 7,2
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
detonation_x:        .res slots
;;; Y coordinate to render the current frame at, taking
;;; into account the individual frame's offset
detonation_cy:       .res slots
detonation_cy2:      .res slots
.export screen_column
screen_column:      .res slots
i_detonation_count: .res 1
hit:      .res 1
fm:      .res 1
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
            lda #0
            sta hit
            sta fm
            rts
.endproc
;;; queue a detonation animation centered at _pl_x, _pl_y
;;; pl_x,pl_y are typically used by the plot routines
;;; and threfore the line drawing routines, it's convenient
;;; to call this after drawing a line, as pl_x,pl_y would contain
;;; the last pixel drawn
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
            ;; save detonation center 
            sec
            sbc #detonation_xoff
            sta detonation_x,x          ;TODO optimize ( delete tay,tya)
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

;;; screen columns for detonations is the first column
;;; as a 16 pixel sprite, it occupies at most 3 columns
;;; we check if we are at x,x+1,x+2
;;; to know if we are potentially in a column of an explosion
;;; once that is known, we check Y coordinates
;;; the original coordinate of the interceptor detonation is known
;;; the bounding rectangle for the explosion lives at
;;; x-detonation_xoff,y-detonation_yoff
;;; once we've established the bounding of the detonation
;;; and we think we are in it, then we need to calculate
;;; our relative position within that box
;;; we can then look at the current 'sprite' that's drawn in
;;; that box and check for a 1 bit at the corresponding location
;;; for this test function we are using the target crosshair
;;; as a proxy for an icbm so I can test.  If that works then
;;; we will substitute an actual ICBM coord
.bss
x_intersect:        .res 1
y_intersect:        .res 1
.code
.export check_collision
.proc check_collision
          ldx #slots - 1
loop:     
          lda i_detonation_frame,x
          ;; negative numbers are finished, 
          ;; or not yet drawn
          bpl active
          jmp next
active:   
          lda target_x                  
          clc
          adc #crosshair_xoff
          sec
          sbc detonation_x,x
          ;; if difference is 0 <= different <= 16
          ;; then  we are in X range
          ;; TODO: optimize, invert logic
          bpl xgreater0
          beq xgreater0
          myprintf2 0,120,"tl"
          
          jmp next
xgreater0: 
          cmp #16
          bcc inside_x
          myprintf2 0,120,"tr"
          
          jmp next
inside_x:           
          ;; save x offset within the bounding column
          sta x_intersect
          lda target_y
          adc #crosshair_yoff
          sec
          sbc detonation_y,x
          ;; 0 <= A <= 16 then in Y rage
          bpl ygreater0
          beq ygreater0
          myprintf2 0,120,"ab"
          
          jmp next
ygreater0:          
          cmp #16
          bcc inside_y
          myprintf2 0,120,"be"
          
          jmp next
inside_y: 
          sta y_intersect
          myprintf2 0,120,"i%d:%d",x_intersect,y_intersect
          
          ;; load the correct collision map for the 
          ;; explosion animation frame being displayed
          ldy i_detonation_frame,x      ;index into frame table
          lda explosion_frame_table,y   ;which image (0-7) is displayed
          sta fm
          tay
          ;; now load the collision map for that image
          lda collision_tableL,y
          sta ptr_0
          lda collision_tableR,y
          sta ptr_0 + 1
          ;; find the byte in explosion collison map
          ;; byte = y*16+x
          lda y_intersect
          ;; multiply by 16
          asl
          asl
          asl
          asl
          ;; add x offset
          clc
          adc x_intersect
          tay
          ;; this byte(not bit), 0 or 1 tells us if there is a hit
          ;; for the underlying pixel. whole bytes were used for speed
          lda (ptr_0),y
          sta hit
          myprintf2 0,130,"h:%d",hit
          
next:     
          dex
          bmi exit
          jmp loop
exit:     
          rts
.endproc
