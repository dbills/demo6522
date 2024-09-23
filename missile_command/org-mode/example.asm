dc.b 1, 2
.repeat 10
.endrepeat
	lda #5
        sta fubar
.proc blarg
	;; do stuff
        
.endproc

dc.b 1, 2
.repeat 10
.endrepeat
          lda #5
          sta fubar
.proc blarg
        ;; do stuff

.endproc
