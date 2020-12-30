          .include   "screen.inc"
          .include   "zerop.inc"         ;must be near top
          .include   "timer.inc"
          .include   "m16.mac"
          .include   "colors.equ"
          .include   "line.inc"
          .include   "math.mac"
          .include   "system.mac"
          .include   "jstick.inc"
          .include   "kplane.mac"
          .include   "target.inc"
          .include   "sprite.inc"
          .include   "text.inc"
          .include   "debugscreen.inc"
;.segment "STARTUP"
;          jmp demo
          .CODE
.proc     demo
          ;; enabling interrupts really pisses the system off with 
          ;; the screen and character configs I have
          movi MINISR, $0314
          ;mov_wi DEFISR, $0314          ;
          cli

          jsr i_pltbl           
          jsr i_chrset
          jsr i_hires
          jsr i_joy
          screenmem SCREEN

          ;; border colors
          invmode 0
          bcolor_i BLUE
          scolor_i PURPLE

          jsr i_debug_screen
.import _c_main, draw_letter1
          mov #_ldata1, _lstore
          lineto 10,1,1,5
          ;lineto 1,1,10,5
	;lineto 0,0,4,4      
          ;jsr _c_main                   
;          jsr bounce                    
          jmp loop
l1:         
          jsr _plot
          inc _pl_x
          inc _pl_y
          lda #172
          cmp _pl_x
          beq loop
          jmp l1

          debug_string "missilecommandtheend" 
loop:       
          jsr j_wfire
          jsr show_debug_screen
          jsr j_wfire
          jsr i_hires
          jmp loop
          rts
.endproc
;;; fill screen with a tiled
;;; set of chars to allow bitmapped
;;; graphics
.proc     i_hires  
          chbase CHBASE1
          setrows SCRROWS
          tallchar              
          ldy SCRMAP_SZ
          ;; fill screen with chars tile
          ;; pattern 
loop:       
          lda #BLUE
          sta CLRRAM-1,y
          lda SCRMAP-1,y
          sta SCREEN-1,y
          dey
          bne loop
          rts
.endproc          
;;; clear ram allocated to custom
;;; character set
.proc     i_chrset
          movi CHBASE1, ptr_0
          ldy #0
          ldx #16                       ;# of pages
          lda #0                        ;AA is nice
loop:       
          sta (ptr_0),y
          iny
          beq inch
          bne loop
inch:       
          inc ptr_0 + 1
          dex
          beq done
          bne loop
done:       
          rts
.endproc
;;; wait vertical blank
.proc       wait_v
iloop:      
          lda VICRASTER           ;load raster line
          bne iloop
          rts
.endproc
.proc     bounce
          lda #SCRROWS*16/2
          sta s_y
          lda #80
          sta s_x
          ldx #S_TARGET
          jsr sp_draw
loop:       
          jsr wait_v
          ldx #S_TARGET
          jsr sp_draw                   ;erase

          ldx #S_TARGET
          jsr moveme

          ldx #S_TARGET
          jsr sp_draw                   ;draw

          jmp loop
          rts
.endproc

.proc     i_intr 
          sei
          lda $bf                       ;eabf
          sta $0314
          lda $ea
          sta $0315
          cli
          rts
.endproc
