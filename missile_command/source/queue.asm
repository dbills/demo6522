.include "m16.mac"
.include "zerop.inc"
.include "line.inc"
.include "queue.mac"
.export queue_tests
.export p_qhead,p_qtail,p_blarg,i_qtail,i_qhead,Q
.data
p_qhead:
          .word 0
p_qtail:
          .word 0
p_blarg:
          .word 0
i_qtail:
          .byte 0
i_qhead:
          .byte 0
Q:
          .res 10
.code

declare_queue_operations "borda" ,i_qhead,i_qtail,\
                          p_qhead,p_qtail,\
                          Q,0,1,2

.proc queue_tests
          jsr queue_init_borda
          jsr enqueue_borda
          jsr queue_size_borda
          jsr dequeue_borda
          jsr queue_size_borda
          rts
.endproc
