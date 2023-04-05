;;; missile detonations
.include "zerop.inc"
.include "new_explosion.inc"
.include "sprite.inc"
.include "m16.mac"
.include "system.inc"
.include "jstick.inc"
.include "screen.inc"
.include "shapes.mac"
.include "colors.equ"

.include "dbgscreen.inc"
.include "text.inc"

;;; Debugging macros
;DISABLE_ANIMATION = 1
;;; End Debugging macros

.export de_queue, de_init, de_test, de_draw, de_hit,de_draw_all,de_update_all
.export de_update, de_erase, de_rand
.import explosion_frame_skip_offsets

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
.ifdef TESTS
.byte 0
.else
.byte 0,1,2,3,4,5,6,7,6,5,4,3,2,1
.endif
sz_explosion_frame_table = (* - explosion_frame_table)
.macro explosion_y_offset_from_frame frame
            7 - frame
.endmacro
.bss
;;; size of array of on screen detonations
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
;;; Y,X coordinates of upper left ( not center ) of explosion
;;; see detonation_xoff, detonation_yoff for distance to center
detonation_y:        .res slots
detonation_x:        .res slots
;;; Y coordinate to render the current frame at, taking
;;; into account the individual frame's offset.  Sprites data
;;; is stored economically - we don't store empty bytes
;;; so the Y start row changes as the height of the detonation 
;;;  ( perhaps I should waste some memory to simplify the code?? )
detonation_cy:       .res slots
detonation_cy2:      .res slots
.export screen_column
screen_column:      .res slots
i_detonation_count: .res 1
de_hit:  .res 1
fm:      .res 1
.code

.code

.proc     de_init
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
          sta de_hit
          sta fm
          rts
.endproc
;;; Queue a detonation animation centered
;;; 
;;; pl_x,pl_y are typically used by the plot routines
;;; and therefore the line drawing routines, it's convenient
;;; to call this after drawing a line, as pl_x, pl_y would contain
;;; the last pixel drawn
;;; 
;;; IN:
;;;   pl_x, pl_y: center of detonation
;;; OUT:
;;;   X,Y,A: clobbered
.proc     de_queue
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
          ;; store upper left coordinates, not center as given
          sec
          sbc #detonation_xoff
          sta detonation_x,x          ;TODO optimize ( delete tay,tya)
          tay                         ;save x coord
          sp_calc_screen_column       ;x/8
          sta screen_column,x
          tya                         ;restore x coord
          and #7                      ;% 8; modulo8
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
          lda #sz_explosion_frame_table - 1
          sta i_detonation_frame,x
          jsr update_detonation_data
          lda #$ff                    ;-1
          sta i_detonation_frame2,x
          rts
.endproc
rmax = YMAX-32
.proc     myrand
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

.proc       de_rand
            jsr myrand
            sta _pl_x
            jsr myrand
            sta _pl_y
            jsr de_queue
            rts
.endproc

.import wait_v
.proc       de_test
          lda #9
          sta _pl_y
          lda #7
          sta _pl_x
          jsr de_queue

          ldx #slots-1      
loop:     
          jsr erase_detonation
          jsr draw_detonation
          jsr update_detonation
          jsr j_wfire
          jmp loop
          rts     
.endproc

;;; Erase and draw detonations ( splosions! )
;;; 
;;; IN:
;;; OUT:
.proc     de_draw_all
          ldx #(slots-1)
          jsr de_erase

          ldx #(slots-1)
          jsr de_draw

          ;; this section would not be time critical
          ;; ( when we get around to optimizing the main loop )

          rts
.endproc

.proc     de_update_all
          ldx #(slots-1)
.ifndef DISABLE_ANIMATION
          ;; skip for now while we test collisions
          jsr de_update
.endif
.endproc
;;; x = explosion to update
;;; note: there is a sequence of animation 'frames' to
;;; show, that sequence is stored at explosion_frame_table.
;;; After an explosion is erased the following is true:
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
;;; Update non-time critical data about a detonation
;;; i.e. these are the things not done during vertical blank
;;; load the next pointers for sprite data, precalculated data, etc
;;; 
;;; IN:
;;;   A: detonation frame
;;;   X: detonation number
;;; OUT:
.proc       update_detonation_data
active:
            lda i_detonation_frame,x
            tay                         ;index into explosion_frame_table
            ;; animation frame offset: y=7-frame number
          lda explosion_frame_table,y
          tay
          lda explosion_frame_skip_offsets,y
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
;;; Erase a detonation ( vblank/time critical )
;;; self-modifying code for dynamic jmp vector
;;; IN:
;;;   X: detonation to erase
;;; OUT:
.proc       erase_detonation
jmp_operand = jmp0 + 1
            lda i_detonation_frame2,x
            bmi done
            lda detonation_proc2L,x
            sta jmp_operand
            lda detonation_proc2H,x
            sta jmp_operand+1
            ldy screen_column,x
            sp_setup_draw
            ldy detonation_cy2,x
jmp0:
            jmp 0                       ;dynamic operand
done:
            rts
.endproc
;;; Draw a detonation ( vblank/time critical )
;;; self-modifying code for dynamic jmp vector
;;; IN:
;;;   X: detonation to draw
;;; OUT:
.proc       draw_detonation
            lda i_detonation_frame,x
            bmi done
jmp_operand = jmp0 + 1
            lda detonation_procL,x
            sta jmp_operand
            lda detonation_procH,x
            sta jmp_operand+1
            ldy screen_column,x
            sp_setup_draw
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
            cmp zp_cnt3                 ;==0
            bne next                    ;then
            routine                     ;execute
next:
            dex
            bpl loop
done:
            rts
.endmacro

.proc       de_update
            lda #0
            sta i_detonation_count
            iterate_detonations jsr update_detonation
            rts
.endproc

.proc       de_erase
            iterate_detonations jsr erase_detonation
            rts
.endproc

.proc       de_draw
            iterate_detonations jsr draw_detonation
            rts
.endproc

.proc       drawit2
            rts
.endproc

;;; Check for collision of an ICBM with a detonation that may be on the screen
;;;
;;; The x,y coordinate of a detonation are stored as the upper left of a
;;; 16x16 sprite [ the actual largest explosion is a 15x15 circle ]
;;; 
;;; The original coordinate of the interceptor detonation, the center of 
;;; the circle can be obtained with:
;;;   {x + detonation_xoff,  y + detonation_yoff}     or
;;;   {x 7, y + 7}
;;;  at the center, of the widest ball of flaming death, you would have
;;;  7 pixel to the left and right, above and below
;;; 
;;; Once we've established we're in the bounding of the detonation
;;; we calculate our offset from top,left ; stored in 
;;; {x_intersect, y_intersect}
;;; That point is the distance from the origin of the bounding box to
;;; the warhead point(pixel) of the enemy ICBM
;;; 
;;; We look at the current 'sprite' that's drawn in that box and check for a
;;; 1 bit at the corresponding location by using a precomputed collision table
;;; 
;;; IN:
;;;   de_checkx, de_checky: pixel to check
;;; OUT:
;;;   X is clobbered
.zeropage
;;; todo: these, of course, should be moved to ZP for speed
x_intersect:        .res 1
y_intersect:        .res 1
de_checkx:          .res 1
de_checky:          .res 1
;;; tallest explosion, therefore the bounding box height
bounding_height = 15  
bounding_width = 15
.code
.export de_check
.exportzp de_checkx, de_checky
.proc de_check
          savex
          lda #0
          sta de_hit
          ;; iterate through detonations
          ldx #slots - 1
loop:     
          lda i_detonation_frame,x
          ;; negative numbers are finished detonations 
          ;; or not yet drawn
          bpl active
          jmp next
active:   
          lda de_checkx
          sec
          sbc detonation_x, x
          bcs xgreater0
          ;te_printf2 #0,#50, "tl"     ; left of bounding box
          jmp next
xgreater0: 
          BRANCH_LT A, #bounding_width, inside_x
          ;te_printf2 #0,#50, "tr"      ; right of bounding box
          jmp next
inside_x:           
          ;; save x offset within the bounding column
          sta x_intersect
          lda de_checky
          sec
          sbc detonation_y,x
          bcs ygreater0
          ;te_printf2 #0,#50, "ab"       ; above bounding box
          jmp next
ygreater0:          
          BRANCH_LT A, #bounding_height, inside_y
          ;; below bounding box
          ;te_printf2 #0,#50, "be"
          jmp next
inside_y: 
          sta y_intersect
          ;te_printf2 #0, #58, "i:%d:%d", x_intersect, y_intersect
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
          ;; byte = y * 16 + x
          lda y_intersect
          ;; multiply by 2 to get byte
          asl
          tay
          ;; figure out if we need the first byte of collision bits
          ;; or the second
          lda #7
          cmp x_intersect
          bgt byte2
          ;; byte1 of collision
          jmp check_collision_bit
byte2:    
          iny
check_collision_bit:          
          lda (ptr_0),y
          ldy x_intersect
          and de_bitpos,y
          sta de_hit
          ;te_printf2 #0,#41, " h:%d", de_hit
          lda de_hit
          beq next
          ;; no more checks, this one hit
exit:     
          resx
          rts                       
next:     
          dex
          bmi exit
          jmp loop
.endproc

.data
de_bitpos:          
.byte 128,64,32,16,8,4,2,1,128,64,32,16,8,4,2,1
.code

.ifdef TESTS

.include "unit_tests.inc"

.export de_unit_test_CY
;;; Test the bounding box and collision detection
;;; this test runs the collision check across a range of Y coords 1 line
;;; above and below the bounding box ( which is 15 )
.proc     de_unit_test_CY
test_bound = 17
          lda #50
          sta _pl_x
          sta _pl_y
          jsr de_queue                  ; queue up detonation
l00:      
          te_pos #0, #0
          te_printf "detonation cy"
          ;; detonation at 50,50

          lda #52
          sta de_checkx
          ;; check collisions at 14 different heights
          lda #50 - 8                   ; 1 line above the bounding box
          sta de_checky

.repeat test_bound                      ; 1 line after the bounding box
          jsr de_check                  
          te_printf " y:%d h:%d", de_checky, de_hit
          inc de_checky
.endrepeat

          te_printf "press trigger"
          jsr j_wfire
          jsr sc_chrset
          te_pos #0, #0
          te_printf "detonation cx"
          ;; 
          ;; == X coords ===
          ;; 
          lda #50
          sta de_checky
          ;; check collisions at different x positions
          lda #50 - 8                   ; 1 line left the bounding box
          sta de_checkx

.repeat test_bound
          jsr de_check                  
          te_printf " x:%d h:%d", de_checkx, de_hit
          inc de_checkx
.endrepeat

          te_printf "press trigger"
          jsr j_wfire
          jsr sc_chrset
          jmp l00

          rts
.endproc
.endif
