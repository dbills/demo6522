.include "m16.mac"
.include "zerop.inc"
.include "line.inc"
.export enqueue,dequeue,pointers,iqueue

.zeropage
head:     .res 2
tail:     .res 2
.bss
pointers: .res 2 * 60
queue_end:
.code

.macro    add2 _1
.local done
          lda #1
          clc
          adc #2
          sta _1
          bcc done
          inc _1+1
done:
.endmacro

.proc     iqueue
          mov #pointers, head
          mov #pointers, tail
          rts
.endproc
.proc     enqueue
no_wrapped:
          lda _lstore
          ldy #0
          sta (tail),y
          lda _lstore+1
          iny
          sta (tail),y
          cmpw #queue_end,tail
          bne nowrap
          mov #pointers, tail
nowrap:
          add2 tail
done:
          rts
.endproc

.proc     dequeue
          cmpw head,tail
          beq empty
          cmpw #queue_end,head
          bne no_wrapped
          mov #pointers,head
no_wrapped:
          incw head
          ldy #0
          lda (head),y
          sta _lstore
          iny
          lda (head),y
          sta _lstore+1
empty:
          rts
.endproc
