.export crosshair,city_left,city_right,base_left,base_right
.listbytes 100
.DATA

;;; left and right right byte of a shift
;;; expands 'in place' as an expression where used
;;; thus .SHIFT refers to some local variable
;;; where this is exa
.macro       sh_left b,shift
            .byte ($ff & (b  >> shift))
.endmacro
.macro       sh_right b,shift
            .byte ($ff & (b  << (8 - shift)))
.endmacro

;;; used the generate the preshifted bytes
;;; of a 16x8 bit sprite
.macro    sh_shift b1,b2,b3,b4,b5,b6,b7,b8
SHIFT     .set 0
          .repeat 8
          sh_left  b1 ,SHIFT 
          sh_left  b2 ,SHIFT
          sh_left  b3 ,SHIFT
          sh_left  b4 ,SHIFT
          sh_left  b5 ,SHIFT
          sh_left  b6 ,SHIFT
          sh_left  b7 ,SHIFT
          sh_left  b8 ,SHIFT

          sh_right b1 ,SHIFT
          sh_right b2 ,SHIFT
          sh_right b3 ,SHIFT
          sh_right b4 ,SHIFT
          sh_right b5 ,SHIFT
          sh_right b6 ,SHIFT
          sh_right b7 ,SHIFT
          sh_right b8 ,SHIFT
SHIFT     .set SHIFT + 1
          .endrepeat
          .endmacro

crosshair:      
.linecont
           sh_shift %00000000,  \
                    %01000010,  \
                    %00100100,  \
                    %00011000,  \
                    %00011000,  \
                    %00100100,  \
                    %01000010,  \
                    %00000000

city_left:     
	.byte %00000010
	.byte %00000010
	.byte %00000110
	.byte %00001111
	.byte %00001111
city_right: 
	.byte %00000000
	.byte %10100000
	.byte %10110100
	.byte %11111110
	.byte %11111111
ground_piece:           
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte %11111111
	.byte %11111111
	.byte %11111111
	.byte %11111111
	.byte %11111111
base_left:  
          .byte %00000000
          .byte %00000011
          .byte %00000111
          .byte %00001111
          .byte %00011111
          .byte %00111111
          .byte %01111111
          .byte %11111111
base_right:
          .byte %00000000
          .byte %11000000
          .byte %11100000
          .byte %11110000
          .byte %11111000
          .byte %11111100
          .byte %11111110
          .byte %11111111

.define MAX_LINES 60
LINE_NUMBER .set 0
.repeat MAX_LINES
  LINE_NUMBER .set LINE_NUMBER + 1
  .ident (.sprintf ("BLARGO%04X", LINE_NUMBER)): 
.byte 4
.endrepeat
