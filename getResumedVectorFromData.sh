#!/bin/bash
#
# Resume a vector file to a mean and std.deviation
# arguments:
#  1. Input data file
# 
# @author: Juan-Carlos Maureira
# INRIA 2009
# 

if [ -z $OMNET_PATH ]
then
	echo "OMNET_PATH variable not present.\n"
  echo "you need to set the variable OMNET_PATH indicating where the omnet 4.0 is installed"
  echo "i.e: export OMNET_PATH=/opt/omnet40"
  exit 1
fi

export PATH=$PATH:${OMNET_PATH}/bin
INPUT_FILES=$1

if [ -z "$INPUT_FILES" ]
then
   echo "usage: $0 input data file.data (willcards allowed)"
fi

echo "Experiment Replica Mean Stdev Module"

find . -name "$INPUT_FILES" | while read file
do
	export MODULE=`echo $file | cut -d- -f 2`
  MODULE=${MODULE/.data/}
  export EXPERIMENTS=`tail -n +2 "$file" | awk '{ print $1 }' | uniq`
  export REPLICAS=`tail -n +2 "$file" | awk '{ print $2 }' | uniq`

  for EXP in $EXPERIMENTS;
  do
    for REP in $REPLICAS;
    do
       DATA=`cat "$file" | grep $EXP | awk -v replica=$REP 'begin {sum=0;sumsq=0;n=0} {if ($2 == replica) { sum+=$4;sumsq+=($4*$4);n+=1} } END {mean=sum/n;var=((1/(n-1)*sumsq) - (mean*mean) ); print mean " " sqrt(var) }'`
       MEAN=`echo $DATA | awk '{print $1}'` 
       STDEV=`echo $DATA | awk '{print $2}'` 
       echo "$EXP $REP $MEAN $STDEV $MODULE"
    done
  done
done
