# generate a text file of screen hiress address
row=0
# screen start
row_addr=$((256*2))
# character base ( hires screen start)
row_addr=$((1024*4))
echo
while [ $row -lt $((11*16)) ]
do
    count=0
    mem=$row_addr
    while [ $count -lt 23 ]
    do
        printf "%x|" $mem
        mem=$(( $mem + (16*11) ))
        count=`expr $count + 1`
    done
    echo 
    row_addr=$((row_addr+1))
    row=$((row+1))
done
echo
