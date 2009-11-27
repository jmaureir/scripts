#!/bin/sh
#
# extract scalar from the experiment (along all the replicas)
# arguments:
#  1. Experiment Name: the basename of the vectors file to be processed.
#  2. Scalar Name: the vector name you want to extract
#  3. Module Filter (optional): optional operation. See scavetool operations for more information
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

export EXPERIMENT="$1"
export SCALAR_NAME="$2"
export MODULE_FILTER="$3"
export OUTPUT_FILE="$4.data"

REPLICA_FILES=`ls $EXPERIMENT-*.sca`

if [ -z "$OUTPUT_FILE" ]
then
	export OUTPUT_FILE="$EXPERIMENT-$SCALAR_NAME.data"
fi

rm -rf $OUTPUT_FILE

echo "Experiment Replica Module Obs" > $OUTPUT_FILE

for file in $REPLICA_FILES;
do
	export REPLICA_ID=`echo "$file" | cut -d. -f 1 | awk -F- '{print $(NF) }'`
	export EXPERIMENT_ID=`echo "$file" | cut -d. -f 1 | awk -v Repl=$REPLICA_ID '{ sub("-"Repl,"",$0);print }'`

	echo "Extracting Scalar $SCALAR_NAME from replica $REPLICA_ID for Experiment $EXPERIMENT_ID";
	mkdir -p $REPLICA_ID
	if [ -z "$MODULE_FILTER" ]
	then
		echo "Extracting scalar $SCALAR_NAME for all the modules"
		scavetool scalar -p "name(\"$SCALAR_NAME\")" -O $REPLICA_ID/out.csv -F csv -V $file
	else
		echo "Extracting scalar $SCALAR_NAME with module filter as $MODULE_FILTER"
		scavetool scalar -p "name(\"$SCALAR_NAME\") and module(\"$MODULE_FILTER\")" -O $REPLICA_ID/out.csv -F csv -V $file
	fi
  tail -n +2 $REPLICA_ID/out.csv | gawk -F, '{print ENVIRON["EXPERIMENT_ID"], ENVIRON["REPLICA_ID"],$3,$4}' >> $OUTPUT_FILE
	rm -rf $REPLICA_ID
done
dos2unix $OUTPUT_FILE
