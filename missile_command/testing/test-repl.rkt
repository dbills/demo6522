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
  (write16 "lstore" #x2000)
  (write8 "x1" 1)
  (write8 "y1" 1)
  (write8 "y2" 3)
  (write8 "x2" 3)
  (call-label "line1"))


(define (my6502hook)
  ;(display (format "6502hook pc=~x\n" get-pc))
  (if (= (get-pc) (get-bp))
      (begin
       (display "breaking now")
       (set-break-now 1))
      #t))


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
  
(define (test1)
  (init-breakpoints)
  (line-test)
  (run-till-break)
  (dump-line-data #x2000 2))
     
