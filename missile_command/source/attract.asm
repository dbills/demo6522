.include "bigletter.inc"
.include "scroller.inc"
.include "detonation.inc"

.export attract
.import test_detonation
.code

.proc attract
            jsr mcommand
            ;jsr i_scroller
            jsr test_detonation
.endproc
