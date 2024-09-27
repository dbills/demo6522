sed -ne '/Segment list/,/Exports list by name/p' ../source/obj/a.map | tail -n +5 > /tmp/foo
DATA_S=$(grep DATA /tmp/foo | awk '{print $2}')
DATA_E=$(grep DATA /tmp/foo | awk '{print $3}')
CODE_S=$(grep CODE /tmp/foo | awk '{print $2}')
CODE_E=$(grep CODE /tmp/foo | awk '{print $3}')
cat > dbg.txt <<EOF
del
cl
ll "vlabels.txt"
w store .pltbl .pltbl_end
break .main_loop
w exec  $DATA_S $DATA_E
w store  $DATA_S $DATA_E
w store $CODE_S $CODE_E
w exec 0 ff
disable 1
g 2200

EOF
