;;; place me last in the 'main' includes
;;; I allocate space for arrays allocated in zp
;;; using variables that subsytem modules may have incremented
          SEG.U     ZEROP
          ;; insert repeat/repend statements
          ;; for any tables built by other
          ;; assembly modules here
          SEG       CODE

z_init    subroutine
          rts
