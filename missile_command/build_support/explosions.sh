# generate explosion graphics
width=1
while [ $width -lt 9 ];do
    shift=0
    while [ $shift -lt 8 ];do
        # output the friendly graphics image
        # prefix with assembler comment character
        echo ";;;explosion width=$width shift=$shift"
        ./a.out explosion print $width $shift | sed -e 's/^\(.*\)/;;;\1/'
        ./a.out explosion data $width $shift
        shift=$((shift + 1))
    done
    width=$((width + 1))
done
