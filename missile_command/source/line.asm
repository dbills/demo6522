.include  "screen.inc"
.include "zerop.inc"
.include "m16.mac"
.include "text.inc"
.include "genline.mac"
.include "debugscreen.inc"
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
.export _genline,_general_render,line_data01
.export line_types, long_axis_start_values, long_axis_lengths, buffer_indices, long_axis_current_values,_iline

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

.define MAX_LINES 60
LINE_NUMBER .set 0
.repeat MAX_LINES
  LINE_NUMBER .set LINE_NUMBER + 1
  .ident (.sprintf ("line_data%02X", LINE_NUMBER)): .res 176
.endrepeat
line_types:               .res MAX_LINES
long_axis_start_values:   .res MAX_LINES
long_axis_lengths:        .res MAX_LINES
buffer_indices:           .res MAX_LINES
long_axis_current_values: .res MAX_LINES

.code
          ;; distance beteen _1 and _2
          ;; Y=value if _2 < _1
          ;; return abs(_2 - _1) in distance
.macro    delta _1,_2,value
.local normal
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
          ldy value
normal:
          ;; C is already set if we directly branch here
          ;; and this performs the +1
          ;; otherwise it's not and this does nothing
          ;; which is fine
          adc #0
.endmacro
.proc     generate_forward_forward_steep
          generate_line_data forward,forward,steep
          rts
.endproc
          ;; generate line
          ;; calculate _dy,dx and err for
          ;; a line
          ;; inputs: _x1,_x2,_y1,_y2
          ;; closed interval
          ;; outputs: _dy,_dx,err
          ;; A=_dy on exit
          ;; preconditions: _y2>_y1
          ;; 0  q1_steep
          ;; 1  q4_steep
          ;; 2  q2_steep
          ;; 3  q3_steep
          ;; 4  q1_shallow
          ;; 5  q4_shallow
          ;; 6  q2_shallow
          ;; 7  q3_shallow
.proc     _genline
          lda #0                        ;err=0
          sta err

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
          ;; cmp line_type::q1_steep
s0:
          bne s1
          generate_line_data forward,forward,steep
          dbgmsg 'A',#0
          rts
s1:
          cmp #line_type::q4_steep
          bne s2
          dbgmsg 'B',#0
          generate_line_data forward,reverse,steep
          rts
s2:
          cmp #line_type::q2_steep
          bne s3
          generate_line_data reverse,forward,steep
          dbgmsg 'C',#0
          rts
s3:
          cmp #line_type::q3_steep
          bne s4
          generate_line_data reverse,reverse,steep
          dbgmsg 'D',#0
          rts
s4:
          cmp #line_type::q1_shallow
          bne s5
          generate_line_data forward,forward,shallow
          dbgmsg 'E',#0
          rts
s5:
          cmp #line_type::q4_shallow
          bne s6
          generate_line_data forward,reverse,shallow
          dbgmsg 'F',#0
          rts
s6:
          cmp #line_type::q2_shallow
          bne s7
          generate_line_data reverse,forward,shallow
          dbgmsg 'G',#0
          rts
s7:
          cmp #line_type::q3_shallow
          bne s8
          generate_line_data reverse,reverse,shallow
          dbgmsg 'H',#0
          rts
s8:
          rts
.endproc

.macro sleep t
          saveall
          ldx #t
          jsr _sleep
          resall
.endmacro
.proc _sleep
loop:
          waitv
          dex
          bne loop
          rts
.endproc
.include "renderline.mac"
;;; right now, all the render routines
;;; start at buffer end and go toward
;;; beginning - loop direction will have to be rewritten
;;; to change this
.macro    _general_render_template render_type
          lda line_types,y
s0:
          cmp #line_type::q1_steep
          bne s1
          dbgmsg 'A',#1
          render_type forward, forward, steep
          rts
s1:
          cmp #line_type::q4_steep
          bne s2
          render_type forward,reverse,steep
          dbgmsg 'B',#1
          rts
s2:
          cmp #line_type::q2_steep
          bne s3
          render_type reverse,forward,steep
          dbgmsg 'C',#1
          rts
s3:
          cmp #line_type::q3_steep
          bne s4
          render_type reverse,reverse,steep
          dbgmsg 'D',#1
          rts
s4:
          cmp #line_type::q1_shallow
          bne s5
          render_type forward,forward,shallow
          dbgmsg 'E',#1
          rts
s5:
          cmp #line_type::q4_shallow
          bne s6
          render_type forward,reverse,shallow
          dbgmsg 'F',#1
          rts
s6:
          cmp #line_type::q2_shallow
          bne s7
          render_type reverse,forward,shallow
          dbgmsg 'G',#1
          rts
s7:
          cmp #line_type::q3_shallow
          bne s8
          render_type reverse,reverse,shallow
          dbgmsg 'H',#1
          rts
s8:
          rts
.endmacro

.proc _general_render
          _general_render_template render_line_data
.endproc
