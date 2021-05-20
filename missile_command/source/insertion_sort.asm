.include  "insertion_sort.mac"
.include "text.inc"
.include "m16.mac"
.include "zerop.inc"
;;; todo: make text routines _not_ use sprite vars
.include "sprite.inc"
.bss
sort_key:           .res 1              ;last insert values
.code

;;; print direct array contents
.macro    direct_access array
          lda array,y
.endmacro
;;; print indirect array contents
.macro    indirect_access array,pointer
          ldx pointer,y
          lda array,x
.endmacro
.macro    print_array_ size,accessor
          .local loop
          ldy #0
loop:
          accessor
          sta scratch
          myprintf "%d,", scratch
          iny
          cpy #size
          bne loop
.endmacro
.macro    print_array array,size
          print_array_ size,{direct_access array}
.endmacro
.macro    print_indirect_array array,pointer,size
          print_array_ size,{indirect_access array, pointer}
.endmacro
.ifdef TESTS
.export insertion_sort_tests
.proc     insertion_sort_tests
insert_point = 1
.data
value_array:        .byte 7,1,5,4,3,2,6
test_array_sz = * - value_array
;;; set a test pattern in the sorted array starting at $A0
;;; so it's easy to spot parts that haven't been set yet
sorted_array:
.repeat test_array_sz,I
          .byte $A0 + I
.endrepeat
.bss
array_start:        .res 1
array_end:          .res 1
scratch:            .res 1
.code
          ;; initialize test data
          lda #0
          sta s_x
          sta s_y
          myprintf "abcdefghijklmnopqrstuvwxyz0123"
          lda #0
          sta array_start
          sta array_end
loop:     
          insertion_sort sorted_array, value_array, array_start, array_end, array_end
          crlf
          print_indirect_array value_array, sorted_array,test_array_sz
          inc array_end
          lda #test_array_sz
          cmp array_end
          bne loop
done:     
          rts
.endproc
.endif
