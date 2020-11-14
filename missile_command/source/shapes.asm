.export BIT_EYES, BORDA, LETA
.listbytes 100
.DATA
;;; reduce column size with word wrap on until
;;; sprite definitions become vertically aligned
BIT_EYES:   
          .byte %00000000
          .byte %00000000
          .byte %00000000
          .byte %11100111
          .byte %10100101
          .byte %11100111
          .byte %00000000
          .byte %00000000

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

BORDA:      
;          sh_shift $80,$80,$80,$80,$80,$80,$80,$80 
;           sh_shift $ff  ,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.linecont
           sh_shift %00000000,  \
                    %01000010,  \
                    %00100100,  \
                    %00011000,  \
                    %00011000,  \
                    %00100100,  \
                    %01000010,  \
                    %00000000

LETA:       
	sh_shift  %00100000,%01010000,%10001000,%11111000,%10001000,%10001000,%10001000,0
