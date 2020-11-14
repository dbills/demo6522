#!/bin/bash
BNAME=`basename $1 .asm`
DNAME=`dirname $1`
MNAME=$DNAME/$BNAME.mac
INAME=$DNAME/$BNAME.inc
echo $1 $BNAME 
sed -ne '/.export/ s/.export/.import/p' $1 > $INAME
if [ -f $MNAME ]
then
    echo ".include \"$MNAME\"" >> $INAME
else
    :
    #echo "no macro $MNAME"
fi

if [ "${2}" == "asm" ]
then
    ca65 --cpu 6502 --list-bytes 0 -l $BNAME.lst $1 2>&1 | sed  -e 's/^\([^(]*\)[(]\([0-9]*\)[)]:/\1:\2:0:/'
fi
