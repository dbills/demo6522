# generate explosion graphics
width=1
echo '.include "zerop.inc"'
echo '.code'
while [ $width -lt 9 ];do
    shift=0
    while [ $shift -lt 8 ];do
        # output the friendly graphics image
        # prefix with assembler comment character
        echo ";;;explosion width=$width shift=$shift"
        ./a.out explosion print $width $shift | sed -e 's/^\(.*\)/;;;\1/'
        #./a.out explosion data $width $shift
        ./a.out explosion templ $width $shift
        shift=$((shift + 1))
    done
    width=$((width + 1))
done
echo ".data"
shift=0
while [ $shift -lt 8 ]; do
    cat <<EOF
;;; table of function pointers to
;;; draw explosions of preshift ${shift}
;;; for each available radius
.export draw_explosion_R_${shift}_table
draw_explosion_R_${shift}_table:
.repeat 8, WIDTH
.word .ident (.sprintf("draw_explosion_%d_shift${shift}", WIDTH + 1))
.endrepeat
EOF
    shift=$((shift + 1))
done

# output interceptor / detonation collision tables
width=1
while [ $width -lt 9 ];do
    ./a.out collision collision $width 0
    width=$((width + 1))
done
# output pointer index table to above table
cat <<EOF
;;; a pointer index table for the previous tables
;;; e.g. void *pointer = collision_table[x]
;;; where X would be one of the 8 possible explosion frame
;;; widths.  
EOF
echo "collision_tableL:"
echo ".export collision_tableL"
width=1
while [ $width -lt 9 ];do
    echo "     .byte <collision_${width}_shift0"
    width=$((width + 1))
done
echo "collision_tableR:"
echo ".export collision_tableR"
width=1
while [ $width -lt 9 ];do
    echo "     .byte >collision_${width}_shift0"
    width=$((width + 1))
done
