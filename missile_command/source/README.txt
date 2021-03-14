notes on source

processor registers are always in caps
e.g. A = accumulator, X = register

limited hungarian:
(one of the few places where it makes sense , assembler )
labels that are intended as indexes are prefixed with i_
labels that are pointers are prefixed with p_
identifiers are in lowercase with the exception of:
  runtime constants are in CAPS
  assembly time templates may be mixed case or CAPS


procedure and macro header comments are:

;;; <description>
;;; IN:
;;;   arg1: does this and that
;;; OUT:
;;;   foo: is updated
;;;   X is clobbered
.proc foo arg1
.endproc

there is a  form of 'double buffering' for shapes
the versions of a variable if the number 2 suffixed
are the old versions of the variable, i.e.
the version to be erased for example
