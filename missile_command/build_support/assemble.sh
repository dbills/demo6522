#!/bin/bash
set -o pipefail
BNAME=`basename $1 .asm`
DNAME=`dirname $1`
MNAME=$DNAME/$BNAME.mac
INAME=obj/$DNAME/$BNAME.inc
#echo $1 $BNAME
echo -e ".ifndef _${BNAME}_H\n_${BNAME}_H = 1" > $INAME
sed -ne '/.scope/p;/[.]export/ s/.export/.import/p' $1 >> $INAME
if [ -f $MNAME ]
then
    echo ".include \"$MNAME\"" >> $INAME
else
    :
    #echo "no macro $MNAME"
fi
echo ".endif ; header guard" >> $INAME

if [ "${2}" == "asm" ]
then
    # sed expression attempts to fixup for emacs compile mode
    ca65 -D ${DEFINES:-debug=1}  -Iobj -v --cpu 6502 --list-bytes 0 -o obj/$BNAME.o -l obj/$BNAME.lst $1 2>&1  | sed  -e 's/^\([^(]*\)[(]\([0-9]*\)[)]:/\1:\2:0:/'
fi
