sed -ne '/Segment list/,/Exports list by name/p' ../source/obj/a.map | tail -n +5 > /tmp/foo
DATA_S=$(grep DATA /tmp/foo | awk '{print $2}')
DATA_E=$(grep DATA /tmp/foo | awk '{print $3}')
CODE_S=$(grep CODE /tmp/foo | awk '{print $2}')
CODE_E=$(grep CODE /tmp/foo | awk '{print $3}')
BSS_S=$(grep BSS /tmp/foo | awk '{print $2}')
BSS_E=$(grep BSS /tmp/foo | awk '{print $3}')
cat > dbg.txt <<EOF
del
cl
ll "vlabels.txt"
w store .pltbl .pltbl_end
;break .blargo
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
w exec 0 ff
disable 1
g 2200
EOF
