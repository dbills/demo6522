;;; emacs - F5 (racket-run-and-switch-to-repl) to start the racket repl
;;;
#lang racket/base
(require "emulator_ffi.rkt")

(define (time-label label)
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

(define (set-linevar x1 x2 y1 y2)
  (write8 "x1" x1)
  (write8 "y1" y1)
  (write8 "y2" y2)
  (write8 "x2" x2)
  (time-label "cdelta")
  (list (read8 "dx") (read8 "dy")))

(define (line-test1)
  "a basic line test for one of the 8 quadrants in bresenham, this would be quadrant 1, dy > dx "
  (let* ((lstore #x4000)
         (y1 1)
         (y2 11)
         (x1 11)
         (x2 17)
         (dy (+ 1 (- y2 y1))))
    (write16 "lstore" (- lstore 1))
    (write8 "x1" x1)
    (write8 "x2" x2)
    (write8 "y1" y1)
    (write8 "y2" y2)
    (memset lstore dy)
    (define elapsed (time-label "line1"))
    (cons elapsed (dump-line-data lstore dy))))
;;; both routines appear to work for diagonal lines
(define (line-test x1 x2 y1 y2 algo)
  "a basic line test for one of the 8 quadrants in besenham, this would be quadrant 1, dy > dx "
  (let* ((lstore #x4000)
         (dy (+ 1 (abs (- y2 y1))))
         (dx (+ 1 (abs (- x2 x1)))))
    (write16 "lstore" (- lstore 1))
    (write8 "x1" x1)
    (write8 "y1" y1)
    (write8 "y2" y2)
    (write8 "x2" x2)
    (memset lstore 176)
    (define elapsed (time-label algo))
    (cons elapsed (dump-line-data lstore (max dx dy)))))

(define (line-test2)
  "a basic line test for one of the 8 quadrants in besenham, this would be quadrant 1, dy > dx "
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
    (memset lstore 176)
    (define elapsed (time-label "line2"))
    (cons elapsed (dump-line-data lstore dx))))

(define (line-draw2) 
  (line-test2)
  (time-label "render2"))


(define (call-label label) 
  "jsr through the cassette buffer for the vic"
  (write-6502 #x003c #x20)             ;jsr
  (write-word #x003d (get-label label))
  (set-pc #x003c)
  (set-bp (+ #x003c 3))
  (set-break-now 0))

(define (my6502hook)
  ;(display (format "~x: A=~x X=~x Y=~x D=~x\n" (get-pc) (get-a) (get-x) (get-y) (read-6502 61)))
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
  ;(load-labels "../labels.txt")
  (load-labels "../source/vlabels.txt")
  (printf "irq/brk = ~x\n" (get-word #xfffe))
  (printf "nmi = ~x\n" (get-word #xfffa))
  (printf "reset = ~x\n" (get-word #xfffc))
  (printf "user = ~x\n" (get-word #x314))
  (hook-external my6502hook)
  (reset-6502)
)


;(hook-external standard-hook)

  
(define (test-assert expected actual message)
  (unless (equal? expected actual) (printf "~s failed ~s != ~s" message expected actual)))

(define (all-tests)
  (setup) 
  (call-label "i_pltbl")
  (call-label "i_hires")
  (call-label "i_chrset")
  
  (test-assert '(0 0 0 0 0 0 0 0 0 0 0) (cdr (line-test 0 0 0 10 "genline")) "vertical")
  (test-assert '(0 0 0 0 0 0 0 0 0 0 0) (cdr (line-test 0 10 0 0 "genline")) "horizonal")
  (test-assert '(0 0 0 0 0 0 0 0 0 0 0) (cdr (line-test 0 0 10 0 "genline")) "vertical")
  (test-assert '(0 0 0 0 0 0 0 0 0 0 0) (cdr (line-test 10 0 0 0 "genline")) "horizonal")
  (let ((seq '(0 1 2 3 4 5 6 7 8 9 10)))
    (test-assert  seq (cdr (line-test 0 10 0 10 "genline")) "diagonal x1<x2")
    (test-assert  (reverse seq) (cdr (line-test 10 0 0 10 "genline")) "diagonal x1>x2")
    )
  (test-assert '(0 1 2 3 4 5 6 7 8 9 10) (cdr (line-test 0 10 0 10 "genline")) "diagonal")
  (let ((seq '(11 11 12 12 13 14 14 15 16 16 17)))
    (test-assert  seq (cdr (line-test 11 17 1 11 "genline")) "line test dx>dy x2>x1")
    (test-assert  (reverse seq) (cdr (line-test 17 11 1 11 "genline")) "line test dx>dy x1>x2"))
  (test-assert '(8 15 21 26 30 33 35 0) (incy-test) "incy"))
  
