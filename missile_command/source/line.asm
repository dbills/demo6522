.include "screen.inc"
.include "zerop.inc"
.include "m16.mac"
.include "text.inc"
.include "genline.mac"
.include "debugscreen.inc"
.include "line.mac"
;;; public line symbols
;;; line* routines put the 'line instructions' in ram
;;; render* routines take a line instruction set and
;;; place on the screen
;;; dx: delta x, the x length of a line
;;; dy: delta y, the y length of a line
;;; lstore: pointer to location to read or write line data
;;; x1,x2,y1,y2: the 2 respective endpoints of a line
;;; NOTE: please see line.txt for
;;; important notes about terms in this file
.exportzp _x1,_x2,_y1,_y2,_lstore,_dx,_dy
.export _genline,_general_render,_partial_render,render_single_pixel,init_lines
.export line_types, long_axis_start_values, long_axis_lengths, line_data_indices, long_axis_current_values,_iline
.export line_data00
.export line_data01
;,line_data03,line_data04,line_data05,line_data06,line_data07,line_data08,line_data09,line_data10,line_data11,line_data12,line_data13,line_data14,line_data15,line_data16,line_data17,line_data18,line_data19,line_data20,line_data21,line_data22,line_data23,line_data24,line_data25,line_data26,line_data27,line_data28,line_data29,line_data30
.ZEROPAGE
line_type:
err:        .res 1
_dx:        .res 1
_dy:        .res 1
_x1:        .res 1
_y1:        .res 1
_x2:        .res 1
_y2:        .res 1
_lstore:    .res 2
_iline:     .res 1

.BSS

.enum line_type
          q1_steep
          q4_steep
          q2_steep
          q3_steep
          q1_shallow
          q4_shallow
          q2_shallow
          q3_shallow
.endenum

;;; generate storage for MAX_LINES
;;; with a label starting at line_data00
;;; byte line_data[LINEMAX][MAX_LINES]
;;; recall C is row-major order
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
;;; E.g. line00 == line_offsetsL[0]<<8+line_ffsetsH[0]
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
          ;; distance beteen _1 and _2
          ;; Y=value if _2 < _1
          ;; return abs(_2 - _1) in distance
.macro    delta _1,_2,value
.local normal,done
          lda _2
          sec
          sbc _1
          bcs normal
          ;; x2 was < x1
          eor #$ff
          ;; we need to add 1 to finish our little 2's complement
          ;; stunt and get to x1-x2 -- and we also
          ;; need to add +1 to dx, so:
          ;; clc implied (or we wouldn't be here)
          adc #2
          ldy value                     ;output return value
          bne done                      ;bra done
normal:
          ;; C is already set if we directly branch here
          ;; and this performs the +1
          ;; otherwise it's not and this does nothing
          ;; which is fine
          adc #0
          ldy #0                        ;no return value
done:     
.endmacro
.proc     generate_forward_forward_steep
          generate_line_data forward,forward,steep
          rts
.endproc
;;; generate line data
;;; IN: _x1,_x2,_y1,_y2,_lstore
;;;   coords are closed interval
;;;   _lstore is pointer to where to store data
;;;   X: index of line
;;; OUT: _dy,_dx,err
;;; A=_dy on exit
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
;;; forms an  acute angle between the X axis
;;; the the line
.proc     _genline
          lda #0                        ;err=0
          sta err
          ;; the delta calls, set 3 bits. for each 
          ;; compare if it was inverted, thus a number
          ;; from 0-7 is generated
          delta _y1,_y2,#1
          sta _dy
          tya
          ora err
          sta err
          delta _x1,_x2,#2
          sta _dx
          tya
          ora err
          sta err
          delta _dx,_dy,#4
          tya
          ora err
          ;; A now has 0-7 to indicate one of the 8 line types
          ;; to be drawn
          ;; line_type;:q1_steep
          ;; pos 0,40
          ;; debug_number A
          ;; crlf
s0:
          ;; optmization note:
          ;; this line could be removed
          cmp #line_type::q1_steep
          bne s1
;          myprintf "ffs"
          generate_line_data forward,forward,steep
          rts
s1:
          cmp #line_type::q4_steep
          bne s2
;          myprintf "frs"
          generate_line_data forward,reverse,steep
          rts
s2:
          cmp #line_type::q2_steep
          bne s3
;          myprintf "rfs"
          generate_line_data reverse,forward,steep
          rts
s3:
          cmp #line_type::q3_steep
          bne s4
;          myprintf "rrs"
          generate_line_data reverse,reverse,steep
          rts
s4:
          cmp #line_type::q1_shallow
          bne s5
;          myprintf "ffa"
          generate_line_data forward,forward,shallow
          rts
s5:
          cmp #line_type::q4_shallow
          bne s6
;          myprintf "fra"
          generate_line_data forward,reverse,shallow
          rts
s6:
          cmp #line_type::q2_shallow
          bne s7
;          myprintf "rfa"
          generate_line_data reverse,forward,shallow
          rts
s7:
          cmp #line_type::q3_shallow
          bne s8
;          myprintf "rra"
          generate_line_data reverse,reverse,shallow
          rts
s8:
          debug_number A
          brk
          rts
.endproc

.include "renderline.mac"
;;; dynamically determine which of the 8 line
;;; rendering strategies are needed and apply
;;; a routine with correct arguments
;;; IN:
;;;   render_type: the routine to apply
;;;   X: index of line
.macro    _general_render_template render_type
.local s0,s1,s2,s3,s4,s5,s6,s7,s8
          lda line_types,x
s0:
          cmp #line_type::q1_steep
          bne s1
;          dbgmsg 'A',#1
          render_type forward, forward, steep
          rts
s1:
          cmp #line_type::q4_steep
          bne s2
;          dbgmsg 'B',#1
          render_type forward,reverse,steep
          rts
s2:
          cmp #line_type::q2_steep
          bne s3
;          dbgmsg 'C',#1
          render_type reverse,forward,steep
          rts
s3:
          cmp #line_type::q3_steep
          bne s4
;          dbgmsg 'D',#1
          render_type reverse,reverse,steep
          rts
s4:
          cmp #line_type::q1_shallow
          bne s5
;          dbgmsg 'E',#1
          render_type forward,forward,shallow
          rts
s5:
          cmp #line_type::q4_shallow
          bne s6
;          dbgmsg 'F',#1
          render_type forward,reverse,shallow
          rts
s6:
          cmp #line_type::q2_shallow
          bne s7
;          dbgmsg 'G',#1
          render_type reverse,forward,shallow
          rts
s7:
          cmp #line_type::q3_shallow
          bne s8
;          dbgmsg 'H',#1
          render_type reverse,reverse,shallow
          rts
s8:
          sta debugb
          dbgmsg 'Q', debugb
          rts
.endmacro

.proc _general_render
          _general_render_template render_line_data
          rts
.endproc

.proc _partial_render
.ifdef debug
          ;; check if line is still in progress
          lda line_data_indices,x
;          bne draw
          ;; abort with code and print register X
          brk
draw:
.endif
          _general_render_template render_partial_line
.endproc

.proc render_single_pixel
          ;abort 'A',X
          _general_render_template render_partial_line
.endproc

.proc     init_lines
          ldx #MAX_LINES-1
loop:
          lda #0
          sta line_data_indices,x
          dex
          bpl loop
          rts
.endproc
