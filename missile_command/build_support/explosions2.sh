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
