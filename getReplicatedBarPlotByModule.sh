#!/bin/bash
#
# Generate a BarPlot from an Scalar Data file from the same experiment, grouped by Replica
# 
# Depends on bargraph.pl from Derek Bruening
# http://www.burningcutlery.com/derek/bargraph/
#
# Arguments:
#  1. Input Data File.
#  2. Experiment
#  3. Mapping File (optional): a mapping file to translate modules name into a user-friendly string
# 
# @author: Juan-Carlos Maureira
# INRIA 2009
# 

if [ $# != 2 ] && [ $# != 3 ] && [ $# != 4 ]
then
   echo "usage: $0 inputfile.data experiment [ylabel] [mapping file]"
   exit 1
fi

INPUT_FILE="$1"
EXPERIMENT=$2
YLABEL="$3"
MAPPING="$4"
MODULES_LIST=`tail -n +2 $INPUT_FILE | awk '{print $3}' | sort -s -g | uniq`
REPLICAS=`tail -n +2  $INPUT_FILE | awk '{print $2}' | sort -s -n | uniq`

if [ -z "$YLABEL" ]
then
   YLABEL="Observations"
fi

DATA=""

for MODULE_ID in $MODULES_LIST;
do
	VALUES=""
	for REPLICA in $REPLICAS;
	do
		VALUE=`cat $INPUT_FILE | gawk -v M="$MODULE_ID" -v E="$EXPERIMENT" -v R=$REPLICA '{if (\$2==R && \$1==E && \$3==M) print \$4}'`
		if [ -x $VALUE ] 
		then
			VALUE="0"
		fi
		VALUES="$VALUES $VALUE"
	done

	MODULE=$MODULE_ID
	if [ ! -x $MAPPING ]
	then
		MODULE=`cat $MAPPING | awk  -v M="$MODULE_ID" '{ if (\$1==M) print $2 }'`
	fi
	DATA="$DATA
$MODULE $VALUES" 

done

REPL="";
for REPLICA in $REPLICAS;
do
	REPL="$REPL;Replica $REPLICA"
done

SCRIPT="
# Clustered Bw Script
=cluster$REPL
# green instead of gray since not planning on printing this
#colors=black,yellow,red
=table
yformat=%g
#=norotate
fontsz=6
legendx=4200
legendy=1450
ylabel=$YLABEL
"

echo "
$SCRIPT
$DATA" | ./bargraph.pl -pdf - > BarPlot-$INPUT_FILE-$EXPERIMENT.pdf
