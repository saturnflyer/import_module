#!/bin/sh
times=$1
shift
a=0
while test $a -lt $times
do
    a=`expr $a + 1`
    echo "$a)"
    $*
done
