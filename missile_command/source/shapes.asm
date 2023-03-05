.export crosshair,crosshair_left,crosshair_right
.listbytes 100
.DATA

;;; left and right right byte of a shift
;;; expands 'in place' as an expression where used
;;; thus .SHIFT refers to some local variable
;;; where this is expanded
.macro       sh_left b,shift
            .byte ($ff & (b  >> shift))
.endmacro
.macro       sh_right b,shift
            .byte ($ff & (b  << (8 - shift)))
.endmacro

;;; used the generate the preshifted bytes
;;; of a 8x8 bit sprite
.macro    sh_shift b1,b2,b3,b4,b5,b6,b7,b8
          .repeat 8,SHIFT
          sh_left  b1 ,SHIFT
          sh_left  b2 ,SHIFT
          sh_left  b3 ,SHIFT
          sh_left  b4 ,SHIFT
          sh_left  b5 ,SHIFT
          sh_left  b6 ,SHIFT
          sh_left  b7 ,SHIFT
          sh_left  b8 ,SHIFT
          .endrepeat

          .repeat 8,SHIFT
          sh_right b1 ,SHIFT
          sh_right b2 ,SHIFT
          sh_right b3 ,SHIFT
          sh_right b4 ,SHIFT
          sh_right b5 ,SHIFT
          sh_right b6 ,SHIFT
          sh_right b7 ,SHIFT
          sh_right b8 ,SHIFT
          .endrepeat
.endmacro

crosshair:
.linecont
          sh_shift  %10001000, \
                    %01010000, \
                    %00100000, \
                    %01010000, \
                    %10001000, \
                    %00000000, \
                    %00000000, \
                    %00000000

crosshair_left = crosshair
crosshair_right = crosshair  + (8*8)

