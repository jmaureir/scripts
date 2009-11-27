#!/bin/bash
#
# Extract statistics from the experiment. Statistics come into the scalar files
# arguments:
#  1. Experiment Name: the basename of the vectors file to be processed.
#  2. Stat Name: the statistic name you want to extract
#  3. splitted (otional): if you put "splitted" as 3ed argument. the script will 
#     generate one file by each module. Otherwise, a single file will be generated
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

if [ $# != 2 -a $# != 3 -a $# != 4 ]
then
   echo "usage: $0 Experiment \"Statistic name\" [split] [output file]"
   echo ""
   echo "optional parameter splited generate one file with each statistic"
   exit 0
fi

EXPERIMENT="$1"
STAT_NAME="$2"
SPLIT="$3"

if [ -z "$SPLIT" ]
then
   SPLIT="no"
fi

if [ "$SPLIT" == "split" ]
then
   SPLIT="yes"
fi

REPLICA_FILES=`ls $EXPERIMENT*.sca`

export OUTPUT_FILE="$4"

if [ -z "$OUTPUT_FILE" ]
then
        export OUTPUT_FILE="$SCALAR_NAME"
fi

if [ "$SPLIT" == "no" ]
then
  echo "Generating one single output file $OUTPUT_FILE.data"
  rm -rf "$OUTPUT_FILE.data"
  echo "Experiment Replica Module count mean min max stddev sum sqrsum " > "$OUTPUT_FILE.data"
else
  echo "Generating one output file by each statistic"
  echo "Experiment Replica Module Obs" > "$OUTPUT_FILE-count.data"
  echo "Experiment Replica Module Obs" > "$OUTPUT_FILE-mean.data"
  echo "Experiment Replica Module Obs" > "$OUTPUT_FILE-min.data"
  echo "Experiment Replica Module Obs" > "$OUTPUT_FILE-max.data"
  echo "Experiment Replica Module Obs" > "$OUTPUT_FILE-stddev.data"
  echo "Experiment Replica Module Obs" > "$OUTPUT_FILE-sum.data"
  echo "Experiment Replica Module Obs" > "$OUTPUT_FILE-sqrsum.data"
fi

for file in $REPLICA_FILES;
do
  echo "procesing $file"
  export REPLICA_ID=`echo $file | cut -d- -f 2 | cut -d. -f 1`
  export EXPERIMENT_ID=`echo $file | cut -d- -f 1`

	MODULES_LIST=`cat $file | grep statistic | grep "$STAT_NAME" | awk '{ print $2 }' | sort -s -g`

  for module in $MODULES_LIST
  do 
     echo "processing module $module"
     MODULE_NAME=`echo $module | sed 's/\[/\\\[/g' | sed 's/\]/\\\]/g'`
     DATA=`cat $file | grep -A 7 statistic | grep -A 7 "$MODULE_NAME" | tail -n +2`

     COUNT=`echo $DATA | awk '{ print $3 }' `
     MEAN=`echo $DATA | awk '{ print $6 }' `
     STDDEV=`echo $DATA | awk '{ print $9 }' `
     SUM=`echo $DATA | awk '{ print $12 }' `
     SQRSUM=`echo $DATA | awk '{ print $15 }' `
     MIN=`echo $DATA | awk '{ print $18 }' `
     MAX=`echo $DATA | awk '{ print $21 }' `

     if [ "$SPLIT" == "no" ] 
     then
        echo "$EXPERIMENT_ID $REPLICA_ID $module $COUNT $MEAN $MIN $MAX $STDDEV $SUM $SQRSUM" >> "$OUTPUT_FILE.data"
     else 
        echo "$EXPERIMENT_ID $REPLICA_ID $module $COUNT" >> "$OUTPUT_FILE-count.data"
        echo "$EXPERIMENT_ID $REPLICA_ID $module $MEAN" >> "$OUTPUT_FILE-mean.data"
        echo "$EXPERIMENT_ID $REPLICA_ID $module $MIN" >> "$OUTPUT_FILE-min.data"
        echo "$EXPERIMENT_ID $REPLICA_ID $module $MAX" >> "$OUTPUT_FILE-max.data"
        echo "$EXPERIMENT_ID $REPLICA_ID $module $STDDEV" >> "$OUTPUT_FILE-stddev.data"
        echo "$EXPERIMENT_ID $REPLICA_ID $module $SUM" >> "$OUTPUT_FILE-sum.data"
        echo "$EXPERIMENT_ID $REPLICA_ID $module $SQRSUM" >> "$OUTPUT_FILE-sqrsum.data"
     fi
  done
done
echo "done"

