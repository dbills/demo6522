.include  "screen.inc"
.include "zerop.inc"
.include "m16.mac"
.include "text.inc"
.include "genline.mac"
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
.export _genline,_render1,_ldata1
.ZEROPAGE
err:        .res 1
_dx:        .res 1
_dy:        .res 1
_x1:        .res 1
_x2:        .res 1
_y1:        .res 1
_y2:        .res 1
_lstore:    .res 2
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

.struct line_buffer
  values .res 16
.endstruct

.struct line_data
  ;short_axis_values .res 176            
  short_axis .tag line_buffer
  render_type .byte
  short_axis_start_value .byte
  buffer_index .byte
.endstruct

_ldata1:      .tag line_data
.CODE
          ;; integer 'bresenham' like
          ;; line drawing routine
          ;; 1 = short axis line length
          ;; 2 = long axis line length
          ;; 3 inx or dex 
          ;; for 1 or 2, e.g. dx or dy
          ;; shift is when the short axis
          ;; must 'shift' due to the error
          ;; rate getting too high
          ;; inputs: Y = current long axis
          ;; position
.macro    step_short_axis saxis,laxis,step_operation
          .local shift
          lda err
          clc 
          adc saxis
          bcs shift
          sta err
          cmp laxis
          bcc noshift                   ;TODO optimize
          beq noshift
shift:    
          sec
          sbc laxis
          sta err
          step_operation
noshift:
.endmacro
          ;; distance beteen _1 and _2
          ;; X=value if _2 < _1
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
          ldx value
normal:   
          ;; C is already set if we directly branch here
          ;; and this performs the +1
          ;; otherwise it's not and this does nothing 
          ;; which is fine
          adc #0
.endmacro
          ;; 
          ;; generate line
          ;; calculate _dy,dx and err for            
          ;; a line
          ;; inputs: _x1,_x2,_y1,_y2
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
          txa
          ora err
          sta err
          delta _x1,_x2,#2
          sta _dx
          txa
          ora err
          sta err
          delta _dx,_dy,#4
          txa
          ora err
          ;; A now has 0-7 to indicate on of the 8 line types
          ;; possible to be drawn
          ;; line_type;:q1_steep
          bne s1
;          generate_line_data forward,forward,steep
          brk
s1:       
          cmp line_type::q4_steep
;          generate_line_data forward,reverse,steep
          bne s2
          brk
s2:       
          cmp line_type::q2_steep
          bne s3
          brk
s3:       
          cmp line_type::q3_steep
          bne s4
          brk
s4:       
          cmp line_type::q1_shallow
          bne s5
          brk
s5:       
          cmp line_type::q4_shallow
          bne s6
          brk
s6:       
          cmp line_type::q2_shallow
          bne s7
          brk
s7:       
          cmp line_type::q3_shallow
          bne s8
          brk
s8:       
          rts
.endproc
          ;; sets up input for genline
          ;; linevars(_x1,_x2,_y1,_y2)
.macro    linevars x1,x2,y1,y2
          lda #x1
          sta _x1
          lda #x2
          sta _x2

          lda #y1
          sta _y1
          lda #y2
          sta _y2
.endmacro

;;; inputs: _dy ,_y2
;;; outputs: none
;;; render a quadrant 1 line
;;; i.e. y2 > y1
;;;      x2 > x1
.proc     _render1
          ldy _dy
          ldx _y2
loop:     
          lda (_lstore),y
          sta _pl_x
          stx _pl_y
          dex       
          jsr _plot
          dey
          bne loop
          rts
.endproc
.macro sleep t
          .local loop
          saveall
          ldx #t
loop:     
          waitv
          dex
          bne loop
          resall
.endmacro
;;; right now, all the render routines
;;; start at buffer end and go toward 
;;; beginning - loop direction will have to be rewritten
;;; to change this
.proc     _general_render
          debug_string "here"
          ldy #.sizeof(line_buffer)
          ;; render_type
          lda (_lstore),y
          cmp #render_class::steep_forward
          bne s1
          brk
s1:
          cmp #render_class::steep_reverse
          bne s2
          brk
s2:
          cmp #render_class::shallow_forward
          bne s3
          brk
s3:        
          cmp #render_class::shallow_reverse
          jmp _shallow_reverse
          bne s4
          jmp _shallow_forward
s4:       brk
          rts
.endproc
;;; dx>dy line
;;; quadrant 1
.proc     _shallow_reverse
          ldy _dx
          ldx _x2
loop:     
;          sleep 60                      
          lda (_lstore),y
          sta _pl_y
          plotm txa
          dex
          dey
          bne loop
          rts
.endproc
;;; dx>dy line
;;; quadrant 2
.proc     _shallow_forward
          ldy _dx
          ldx _x1
loop:     
          lda (_lstore),y
          sta _pl_y
          plotm txa
          dex
          dey
          bne loop
          rts
.endproc

.export XBMASKS_OFFSET_TBL, XBMASKS_0,XBMASKS_1,XBMASKS_2,XBMASKS_3,XBMASKS_4,XBMASKS_5,XBMASKS_6,XBMASKS_7
.DATA
XBMASKS_OFFSET_TBL: 
          .byte 8
          .byte 15
          .byte 21
          .byte 26
          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 15
          .byte 21
          .byte 26
          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 21
          .byte 26
          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 26
          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 30
          .byte 33
          .byte 35
          .byte 0

          .byte 33
          .byte 35
          .byte 0

          .byte 35
          .byte 0

          .byte 0

XBMASKS_0:
          .byte %10000000
          .byte %11000000
          .byte %11100000
          .byte %11110000
          .byte %11111000
          .byte %11111100
          .byte %11111110
          .byte %11111111
XBMASKS_1:          
          .byte %1000000
          .byte %1100000
          .byte %1110000
          .byte %1111000
          .byte %1111100
          .byte %1111110
          .byte %1111111
XBMASKS_2:          
          .byte %100000
          .byte %110000
          .byte %111000
          .byte %111100
          .byte %111110
          .byte %111111
XBMASKS_3:          
          .byte %10000
          .byte %11000
          .byte %11100
          .byte %11110
          .byte %11111
XBMASKS_4:          
          .byte %1000
          .byte %1100
          .byte %1110
          .byte %1111
XBMASKS_5:          
          .byte %100
          .byte %110
          .byte %111
XBMASKS_6:          
          .byte %10
          .byte %11
XBMASKS_7:          
          .byte %1

