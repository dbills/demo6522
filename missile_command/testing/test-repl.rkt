;;; emacs - F5 (racket-run-and-switch-to-repl) to start the racket repl
;;;
#lang racket/base
(require "emulator_ffi.rkt")

(define (time-label label)
  (init-breakpoints)
  (call-label label)
  (define cycle-start (get-cycle-count))
  (run-till-break)
  (define cycle-end (get-cycle-count))
;  (printf "s=~s e=~s\n" cycle-start cycle-end)
  (- cycle-end cycle-start))

(define (run-till-break)
  (step-6502) 
  (if (= 0 (get-break-now))
      (run-till-break)
      #f))

(define (incy number)
  (define var "xbmask_pidx")
  (write8 var number)
  (time-label "increment_y")
  (read8 var))

(define (incy-test)
  "tests moving the the next Y coordinate when drawing a line where DX > DY"
  (define (loop accum)
    (define number (car accum))
    (if (= number 0) accum
        (loop (cons (incy number) accum))))
  (reverse (loop (list 8))))

(define (line-test)
  "a basic line test for one of the 8 quadrants in besenham, this would be quadrant 1, dy > dx "
;  (init-breakpoints)
  (let* ((lstore #x4000)
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
    (cons elapsed (dump-line-data lstore dy))))

(define (line-test2)
  "a basic line test for one of the 8 quadrants in besenham, this would be quadrant 1, dy > dx "
;  (init-breakpoints)
  (let* ((lstore #x4000)
         (y1 10)
         (y2 15)
         (x1 1)
         (x2 11)
         (dx (+ 1 (- x2 x1))))
    (write16 "lstore" (- lstore 1))
    (write8 "x1" x1)
    (write8 "y1" y1)
    (write8 "y2" y2)
    (write8 "x2" x2)
    (memset lstore 160)
    (define elapsed (time-label "line2"))
    (cons elapsed (dump-line-data lstore dx))))

(define (line-draw2) 
  (line-test2)
  (time-label "render2"))


(define (my6502hook)
  ;(display (format "6502hook pc=~x\n" (get-pc)))
  (if (= (get-pc) (get-bp))
      (begin
        ;(display "breaking now")
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
  (hook-external my6502hook)
  (reset-6502)
)


;(hook-external standard-hook)

(define (init-breakpoints)
  (set-bp 0)
  (set-break-now 0))
  
(define (test-assert expected actual message)
  (unless (equal? expected actual) (printf "~s failed ~s != ~s" message expected actual)))

(define (all-tests)
  (setup) 
  (test-assert '(11 12 12 13 14 14 15 16 16 17 17) (cdr (line-test)) "line1 test")
  (test-assert '(8 15 21 26 30 33 35 0) (incy-test) "incy"))
  
