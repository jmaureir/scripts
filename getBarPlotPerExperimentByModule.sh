#!/bin/bash
#
# Generate a BarPlot from an Scalar Data file
# 
# Depends on bargraph.pl from Derek Bruening
# http://www.burningcutlery.com/derek/bargraph/
#
# Arguments:
#  1. Input Data File.
#  2. Replica : Replica to chart
#  3. Mapping File (optional): a mapping file to translate modules name into a user-friendly string
# 
# @author: Juan-Carlos Maureira
# INRIA 2009
# 

if [ $# != 2 ] && [ $# != 3 ] && [ $# != 4 ]
then
   echo "usage: $0 inputfile.data replica [ylabel] [mapping file]"
   exit 1
fi

INPUT_FILE="$1"
REPLICA=$2
YLABEL="$3"
MAPPING="$4"
MODULES_LIST=`tail -n +2 $INPUT_FILE | awk '{print $3}' | sort -s -g | uniq`
EXPERIMENTS=`tail -n +2  $INPUT_FILE | awk '{print $1}' | sort -s | uniq`

if [ -z "$YLABEL" ]
then
   YLABEL="Observations"
fi

DATA=""

for MODULE_ID in $MODULES_LIST;
do
	VALUES=""
	for EXPERIMENT in $EXPERIMENTS;
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

EXPR="";
for EXPERIMENT in $EXPERIMENTS;
do
	EXPR="$EXPR;$EXPERIMENT"
done

SCRIPT="
# Clustered Bw Script
=cluster$EXPR
# green instead of gray since not planning on printing this
#colors=black,yellow,red
=table
yformat=%g
=norotate
fontsz=12
legendx=4200
legendy=1450
ylabel=$YLABEL
extraops=set yrange [0:300]
"

echo "
$SCRIPT
$DATA" | ./bargraph.pl -pdf - > BarPlot-$INPUT_FILE-Replica-$REPLICA.pdf
