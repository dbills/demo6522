.include "jstick.inc"
.include "system.mac"
.include "line.inc"
.include "m16.mac"
.include "zerop.inc"
.include "screen.inc"
.import _ldata1
.export   moveme           

          .macro mov_l
          .local done
          lda #0
          cmp s_x,x
          beq done
          dec s_x,x
done:       
          .endmacro

          .macro mov_r
          .local done
          lda #(SCRCOLS*8)-8-1
          cmp s_x,x
          bcc done
          inc s_x,x
done:       
          .endmacro

          .macro mov_d
          .local done
          lda #SCRROWS*16-8-1
          cmp s_y,x
          bcc done
          inc s_y,x
done:       
          .endmacro

          .macro mov_u
            .local done
          lda #0
          cmp s_y,x
          beq done
          dec s_y,x
done:       
          .endmacro
          
.proc     moveme
          jsr j_read
          cmp #JOYU
          beq joyu
          cmp #JOYD
          beq joyd
          cmp #JOYL
          beq joyl
          cmp #JOYR
          beq joyr
          cmp #JOYR & JOYU
          beq joyru
          cmp #JOYL & JOYU
          beq joyul
          cmp #JOYL & JOYD
          beq joydl
          cmp #JOYR & JOYD
          beq joyrd
          cmp #JOYT
          beq joyt
          cmp #JOYT & JOYR
          beq joyrt
          rts
joyrd:      
          mov_r
          mov_d
          rts
joyru:      
          mov_r
          mov_u
          rts
joydl:      
          mov_d
          mov_l
          rts
joyul:      
          mov_u
          mov_l
          rts
joyd:       
          mov_d
          rts
joyu:       
          mov_u
          rts
joyr:       
          mov_r
          rts
joyl:       
          mov_l
          rts
joyt:       
          ;jsr j_tup
          jsr j_tup
          jsr lineto
          rts
joyrt:      
          jsr lineto
          mov_r
          rts
.endproc
;;; inputs: x sprite to draw line to
.proc     lineto
          saveall
          ;; set x1,x2,y1,y2
          ;lda #0
          lda #175/2
          sta _x1
          lda #0
          sta _y1
          lda s_x,x
          sta _x2
          lda s_y,x
          sta _y2

          movi _ldata1-1,_lstore
          jsr _genline
;          jsr line1
;          jsr render1
;          jsr line2
;          jsr render2
          resall
          rts
.endproc
