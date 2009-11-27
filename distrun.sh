#!/bin/sh
#
# Distribute exection of an script in a make file with the option -j
# parameters are given as lists separated by space
#
# Juan-Carlos Maureira
# INRIA 2009

jflag=0
cflag=0
vflag=0
ncpus=1

while getopts 'j:v:c' OPTION
do
  case $OPTION in
  j)	jflag=1
 	ncpus="$OPTARG" 
	;;
  c)	cflag=1
	cmd="$OPTARG"
	;;
  v)	vflag=1
	param="$OPTARG"
	;;
  ?)	printf "Usage: %s: [-j num_cpus] [-v var=list] [-c command]\n" $(basename $0) >&2
	exit 2
	;;
  esac
done
shift $(($OPTIND - 1))

if [ "$cflag" == "0" ]
then
  echo "you must specify a command to run with the -c command args"
  exit 1
fi

VARNAME=" "
VARLIST=" "
if [ "$vflag" == "1" ]
then
  VARNAME=`echo $param | cut -d= -f 1`
  VARLIST=`echo $param | cut -d= -f 2`

  #echo "Variable: $VARNAME"
  #echo "Values  : $VARLIST"

fi

MAKEFILE=`mktemp`
count=0
MAKEFILE_BODY=""
MAKEFILE_PHONY=""

for param in $VARLIST
do
   CMD="$cmd"
   ARGS="$*"

   ARGS=`echo $ARGS | awk -v search=$VARNAME -v repl=$param '{ gsub(search,repl,$0);print}'`

   #echo "running $CMD $ARGS"

   MAKEFILE_BODY="$MAKEFILE_BODY r$count:
	$CMD $ARGS
"
   MAKEFILE_PHONY="$MAKEFILE_PHONY r$count"
   let count=$count+1
done

echo "
.PHONY:	$MAKEFILE_PHONY

all:	$MAKEFILE_PHONY

$MAKEFILE_BODY
" > $MAKEFILE

make -j$ncpus -f $MAKEFILE

rm $MAKEFILE
