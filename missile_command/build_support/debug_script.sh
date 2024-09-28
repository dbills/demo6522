sed -ne '/Segment list/,/Exports list by name/p' ../source/obj/a.map | tail -n +5 > /tmp/foo
DATA_S=$(grep DATA /tmp/foo | awk '{print $2}')
DATA_E=$(grep DATA /tmp/foo | awk '{print $3}')
CODE_S=$(grep CODE /tmp/foo | awk '{print $2}')
CODE_E=$(grep CODE /tmp/foo | awk '{print $3}')
BSS_S=$(grep BSS /tmp/foo | awk '{print $2}')
BSS_E=$(grep BSS /tmp/foo | awk '{print $3}')
if grep gb1 vlabels.txt
then
    GUARD1="w store .gb1 .gb2"
fi
if grep gb3 vlabels.txt
then
    GUARD2="w store .gb3 .gb4"
fi
cat > dbg.txt <<EOF
del
cl
ll "vlabels.txt"
attach disk.64 8
l "a.p00" 8
break .blargo
w store .pltbl .pltbl_end
w exec  $DATA_S $DATA_E
w store  $DATA_S $DATA_E
w exec  $BSS_S $BSS_E
;
; break on write to code segment
; omitting the self-modifying code
;
w store $CODE_S .cw1_s
w store .cw1_e .cw2_s
w store .cw2_e .cw3_s
w store .cw3_e .cw4_s
w store .cw4_e $CODE_E
; temporary debugging guard
$GUARD1
$GUARD2
w exec 0 ff
disable 2
command 1 "enable 2;g"
g 2200
EOF
