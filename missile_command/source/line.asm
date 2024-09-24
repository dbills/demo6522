.include "screen.inc"
.include "zerop.inc"
.include "m16.mac"
.include "text.inc"
.include "genline.mac"
.include "dbgscreen.inc"
.include "line.mac"
;;; public line symbols
;;; line* routines put the 'line instructions' in ram
;;; render* routines take a line instruction set and
;;; place on the screen
;;; dx: li_delta x, the x length of a line
;;; dy: li_delta y, the y length of a line
;;; lstore: pointer to location to read or write line data
;;; x1,x2,y1,y2: the 2 respective endpoints of a line
;;; NOTE: please see line.txt for
;;; important notes about terms in this file
.exportzp z_x1, z_x2, z_y1, z_y2, z_lstore, z_dx, z_dy
.export li_genline, li_full_render, li_render_pixel
.export li_init, line_types, long_axis_start_values, long_axis_lengths
.export line_data_indices, long_axis_current_values, z_iline
.export line_data00,line_data01,line_data02
;,line_data03,line_data04,line_data05,line_data06,line_data07,line_data08,line_data09,line_data10,line_data11,line_data12,line_data13,line_data14,line_data15,line_data16,line_data17,line_data18,line_data19,line_data20,line_data21,line_data22,line_data23,line_data24,line_data25,line_data26,line_data27,line_data28,line_data29,line_data30

.ZEROPAGE

z_line_type:
z_err:        .res 1
z_dx:        .res 1
z_dy:        .res 1
z_x1:        .res 1
z_y1:        .res 1
z_x2:        .res 1
z_y2:        .res 1
z_lstore:    .res 2
z_iline:     .res 1

.BSS

.enum z_line_type
          q1_steep
          q4_steep
          q2_steep
          q3_steep
          q1_shallow
          q4_shallow
          q2_shallow
          q3_shallow
.endenum

;;; Generate storage for MAX_LINES
;;; with a label starting at line_data00
;;; byte line_data[LINEMAX][MAX_LINES]
;;; recall the C language is row-major order
;;; line_dataX[0] = target city.  This first byte is unused by the line rendering
;;; code to save a cycle on loops.  E.g. dec, and beq together
.repeat MAX_LINES,I
  .ident (.sprintf ("line_data%02d", I)): .res LINEMAX
.endrepeat
line_types:               .res MAX_LINES
long_axis_start_values:   .res MAX_LINES
;;; total length ( const )
long_axis_lengths:        .res MAX_LINES
;;; current index in the line?
line_data_indices:        .res MAX_LINES
;;; short axis point?
long_axis_current_values: .res MAX_LINES
.data
;;; low, high bytes for line data
;;; E.g. line00 = (line_offsetsL[0] << 8) + line_offsetsH[0]
;;; and so on...
line_offsetsL:
.export line_offsetsL
.repeat MAX_LINES,I
.byte <(line_data00 + (LINEMAX * I))
.endrep
line_offsetsH:
.export line_offsetsH
.repeat MAX_LINES,I
.byte >(line_data00 + (LINEMAX * I))
.endrep

.code
;;; Generate line data
;;; IN: z_x1, z_x2, z_y1, z_y2,z_lstore
;;;   coords are closed interval
;;;   z_lstore is pointer to where to store data
;;;   X: index of line
;;; OUT: z_dy,z_dx,z_err
;;; A=z_dy on exit
;;; 0  q1_steep
;;; 1  q4_steep
;;; 2  q2_steep
;;; 3  q3_steep
;;; 4  q1_shallow
;;; 5  q4_shallow
;;; 6  q2_shallow
;;; 7  q3_shallow
;;; debug printouts are as follows:
;;; first letter - X axis
;;; second letter - Y axis
;;; third letter steep or acute
;;; e.g FFA
;;; line goes from left to right and
;;; top to bottom of screen
;;; forms an acute angle between the X axis
;;; the the line
.proc     li_genline
          lda #0                        ;z_err=0
          sta z_err
          ;; the li_delta macro calls build a 3 bit number
          ;; we check which way the line runs left or right, up or down
          ;; by subtracting endponts, and then determine slope by dy - dx
          ;; we end up with a # from 0-7 for the type/class of line to draw
          li_delta z_y1,z_y2,#1
          sta z_dy
          tya
          ora z_err
          sta z_err
          li_delta z_x1,z_x2,#2
          sta z_dx
          tya
          ora z_err
          sta z_err
          li_delta z_dx,z_dy,#4
          tya
          ora z_err
          ;; A now has 0-7 to indicate one of the 8 line types
          ;; to be drawn
s0:
          ;; optmization note:
          ;; this line could be removed
          cmp #z_line_type::q1_steep
          bne s1
;          te_printf "ffs"
          generate_line_data forward,forward,steep
          rts
s1:
          cmp #z_line_type::q4_steep
          bne s2
;          te_printf "frs"
          generate_line_data forward,reverse,steep
          rts
s2:
          cmp #z_line_type::q2_steep
          bne s3
;          te_printf "rfs"
          generate_line_data reverse,forward,steep
          rts
s3:
          cmp #z_line_type::q3_steep
          bne s4
;          te_printf "rrs"
          generate_line_data reverse,reverse,steep
          rts
s4:
          cmp #z_line_type::q1_shallow
          bne s5
;          te_printf "ffa"
          generate_line_data forward,forward,shallow
          rts
s5:
          cmp #z_line_type::q4_shallow
          bne s6
;          te_printf "fra"
          generate_line_data forward,reverse,shallow
          rts
s6:
          cmp #z_line_type::q2_shallow
          bne s7
;          te_printf "rfa"
          generate_line_data reverse,forward,shallow
          rts
s7:
          cmp #z_line_type::q3_shallow
          bne s8
;          te_printf "rra"
          generate_line_data reverse,reverse,shallow
          rts
s8:
          debug_number A
          brk
          rts
.endproc

.include "renderline.mac"
;;; Dynamically determine which of the 8 line
;;; rendering strategies are needed and apply
;;; a routine(function) with correct arguments.
;;; 
;;; (perhaps?) more formally:
;;; f(L,g) = g(a,b,c)
;;; where L = some existing pre-rendered line ( given in register X )
;;; and   G = some three argument function(macro in this case)
;;; 
;;; The class of functions(macros) G represents are rendering functions, and
;;; G could be, for example, a function to draw a single pixel of a line to
;;; the screen,or G could be a function to generate precalculated line data into
;;; a buffer
;;; 
;;; IN:
;;;   render_type: the routine to apply.  This is a 3 argument 
;;;                macro to run
;;;   X: index of line
.macro    _general_render_template render_type
.local s0,s1,s2,s3,s4,s5,s6,s7,s8
          lda line_types,x
s0:
          cmp #z_line_type::q1_steep
          bne s1
;          dbgmsg 'A',#1
          render_type forward, forward, steep
          rts
s1:
          cmp #z_line_type::q4_steep
          bne s2
;          dbgmsg 'B',#1
          render_type forward,reverse,steep
          rts
s2:
          cmp #z_line_type::q2_steep
          bne s3
;          dbgmsg 'C',#1
          render_type reverse,forward,steep
          rts
s3:
          cmp #z_line_type::q3_steep
          bne s4
;          dbgmsg 'D',#1
          render_type reverse,reverse,steep
          rts
s4:
          cmp #z_line_type::q1_shallow
          bne s5
;          dbgmsg 'E',#1
          render_type forward,forward,shallow
          rts
s5:
          cmp #z_line_type::q4_shallow
          bne s6
;          dbgmsg 'F',#1
          render_type forward,reverse,shallow
          rts
s6:
          cmp #z_line_type::q2_shallow
          bne s7
;          dbgmsg 'G',#1
          render_type reverse,forward,shallow
          rts
s7:
          cmp #z_line_type::q3_shallow
          bne s8
;          dbgmsg 'H',#1
          render_type reverse,reverse,shallow
          rts
s8:
          sta debugb
          dbgmsg 'Q', debugb
          rts
.endmacro

.proc li_full_render
          _general_render_template render_line_data
          rts
.endproc
;;; Plot the next pixel of an active line
;;; IN:
;;;   X: the active line
;;; OUT:
;;;   Z: true if line is finished
;;;   _pl_x: x coord of pixel just plotted
;;;   _pl_y: to coord of pixel just plotted
.proc li_render_pixel
          _general_render_template render_partial_line
.endproc
;;; Initialize line metadata to inactive
;;; IN:
;;; OUT:
;;;   line_data_indices: set to 0 for all lines
;;;   Y: unchanged
;;;   pl_x, pl_y coord of last pixel drawn
;;; 
.proc     li_init
          ldx #MAX_LINES-1
          lda #0
loop:
          sta line_data_indices,x
          dex
          bpl loop
          rts
.endproc
