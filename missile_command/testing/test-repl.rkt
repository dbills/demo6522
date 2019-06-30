;;; emacs - F5 (racket-run-and-switch-to-repl) to start the racket repl
;;;
#lang racket/base
(require "emulator_ffi.rkt")

(define (run-till-break)
  (step-6502) 
  (if (= 0 (get-break-now))
      (run-till-break)
      #f))
      
(define (line-test)
  "a basic line test for one of the 8 quadrants in besenham, this would be quadrant 1, dy > dx "
;  (init-breakpoints)
  (let* ((lstore #x2000)
         (y1 1)
         (y2 11)
         (x1 11)
         (x2 17)
         (dy (+ 1 (- y2 y1))))
    (write16 "lstore" (- lstore 1))
    (write8 "x1" x1)
    (write8 "y1" y1)
    (write8 "y2" y2)
    (write8 "x2" x2)
    (memset lstore 160)
    (define elapsed (time-label "line1"))
;    (run-till-break)
    (list elapsed (dump-line-data lstore dy))))

(define (my6502hook)
  ;(display (format "6502hook pc=~x\n" get-pc))
  (if (= (get-pc) (get-bp))
      (begin
        ;;(display "breaking now")
       (set-break-now 1))
      #t))


(define (memset start_addr len)
  (define end (+ start_addr len))
  (define (loop start)
                  (if (= start end) #t
                      (begin
                        (write-6502 start #xff)
                        (loop (+ start 1)))))
  (loop start_addr))

(define (dump-line-data start_addr len)
  (define end (+ start_addr len))
  (define (loop start accum)
                  (if (= start end) accum
                      (loop (+ start 1) (cons (read-6502 start) accum))))
  (reverse (loop start_addr  null)))

(define (setup)
  (load-kernel)
  (load-p00 "../a.p00")
  (load-labels "../labels.txt")
  (printf "irq/brk = ~x\n" (get-word #xfffe))
  (printf "nmi = ~x\n" (get-word #xfffa))
  (printf "reset = ~x\n" (get-word #xfffc))
  (printf "user = ~x\n" (get-word #x314))
  (hook-external my6502hook))
;(hook-external standard-hook)

(define (init-breakpoints)
  (set-bp 0)
  (set-break-now 0))
  
