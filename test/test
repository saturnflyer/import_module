#!/bin/sh
modes="mpuscbaqh"
all_option="m s p u h"
script="./test-import-module.rb"
devdir="../develop"
time_script="$devdir/test-time.rb"
time_prog="$devdir/test-time.rb"
times_do_script="$devdir/times-do.sh"
statics="$devdir/statics.rb"

set_program() {
    case $1 in
#	m) option="";;
	m) option=m;;
	p) option=p;;
	q) option=q;;
	h) option=h;;
	u) option=u;;
	s) option=s;;
	c) option=c;;
	b) option=b;;
	a) option=a;;
	*) option=$1;;
    esac
    program="$script $option $args"
}

test_list() {
    for opt in $*
    do
	set_program $opt
	#echo $program; continue
	if $program; then
	    :
	else
	    exit
	fi
    done
}

search_args() {
    args=""
    opts=""
    for arg in $*
    do
	case $arg in
	    [$modes]) opts="$opts $arg";;
	    *.rb) opts="$opts $arg";;
	    times) times_sw="true";;
	    time) timetest=time; script=$time_script;;
#	    *) args="$args $arg";;
	    *) if [ "$times_sw" ]; then
		 times_sw=""
		 times_do=$arg
	       else
		 args="$args $arg"
	       fi;;
	esac
    done
}

search_args $*

if [ "$times_do" ]; then
    $times_do_script $times_do $0 time $opts $args | $statics
elif [ "$timetest" ]; then
    if [ ! "$opts" ]; then
	opts="s m p c"
    fi
    test_list $opts
#    echo $time_prog $opts $args
else
    if [ "$opts" ]; then
	test_list $opts
	echo $opts IS GOOD.
#    elif [ ! "$*" ]; then
    elif :; then
	test_list $all_option
	echo $all_option IS GOOD.
    else
	echo "$0          ... do all test"
	echo "$0 m        ... do multi-thread test"
	echo "$0 s        ... do single thread test ($import_module_s)"
	echo "$0 p        ... do multi-thread test  ($import_module_p)"
	echo "$0 u        ... do multi-thread test  ($import_module_u)"
	echo "$0 h        ... do multi-thread test  ($import_module_h)"
	echo "$0 time [N] [mspucba] [L|S] ... time test (do N loops)"
	echo "$0 times [n] [N] [mspucba] [L|S] ... Statics"
    fi
fi

