;; Collision Detection

;; column = screen column
;; row 0 = the count of items in this row
;; row 1 ... N the index of the player interceptor
;;                        0   1   2   3
;; ---------------------+-----------------------
;; count                | 1   0   0   2
;; interceptor 1        | 13          7
;; interceptor 2        |             2
;; ...                  |
;; interceptor N        |

;; In this layout:
;; screen column three current has 2 player interceptors in it
;; they are interceptor index 2 and 7
;; screen column 0 has 1 interceptor, of index 13
.include "screen.inc"
CO_MAXINTERCEPTOR = 20
co_interceptor_table:         .res CO_MAXINTERCEPTOR * SCRCOLS
co_interceptor_table_ptrL:         
.repeat SCRCOLS, I
          .byte <(co_interceptor_table + (CO_MAXINTERCEPTOR * I))
.endrepeat
co_interceptor_table_ptrH:         
.repeat SCRCOLS, I
          .byte >(co_interceptor_table + (CO_MAXINTERCEPTOR * I))
.endrepeat
