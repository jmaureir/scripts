#!/bin/bash
#
# Generate an Observation Plot from Observations against simulation time
# arguments:
#  1. Input Data file. must come from getDataFromReplicatedVector
#  2. Experiment Name 
#  3. Axe-Y label. when ommited, Observations will be the label on Y
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

if [ $# != 1 ] && [ $# != 2 ] && [ $# != 3 ] && [ $# != 4 ] && [ $# != 5 ]
then
   echo "usage: $0 inputfile.data experiment [ylabel] [title] [byexperiment]"
   exit 1
fi
 
INPUT_FILE=$1
EXPERIMENT=$2
YLABEL=$3
TITLE=$4
BYEXPERIMENT=$5

if [ -z "$YLABEL" ]
then
  YLABEL="Observations"
fi

REPLICAS=`tail -n +2 "$INPUT_FILE" | awk '{print $2}' | sort | uniq`

if [ -z "$BYEXPERIMENT" ] 
then
  BYEXERIMENT="no"
else
  BYEXPERIMENT="yes"
fi

LINETYPE="1"

if [ -n "$EXPERIMENT" ]
then
	EXPERIMENT_LIST=$EXPERIMENT
else
	EXPERIMENT_LIST=`tail -n +2 "$INPUT_FILE" | awk '{print $1}' | uniq`
  NUM_EXP=`echo $EXPERIMENT_LIST | wc | awk '{ print $2 }'`
  LINETYPE=`seq 1 $NUM_EXP`
fi

if [ -z "$TITLE" ]
then
  TITLE="$YLABEL v/s Time"
fi

COUNT=0

for e in $EXPERIMENT_LIST
do
  let COUNT=$COUNT+1
	for r in $REPLICAS
	do
		if [ "$BYEXPERIMENT" == "yes" ]
    then
 			LT=`echo $LINETYPE | cut -d " " -f $COUNT`
   		PLOT_CMD="$PLOT_CMD \"<cat \\\"$INPUT_FILE\\\" | awk '{ if (\$1 == \\\"$e\\\" && \$2 == $r) print \$3 \\\" \\\" \$4 }'\" using 1:2 notitle w l lt $LT,"
    else 
			PLOT_CMD="$PLOT_CMD \"<cat \\\"$INPUT_FILE\\\" | awk '{ if (\$1 == \\\"$e\\\" && \$2 == $r) print \$3 \\\" \\\" \$4 }'\" using 1:2 title \"Experiment $e Replica $r\" w l,"
    fi
	done
done
PLOT_CMD=${PLOT_CMD%,}

GNUPLOT_SCRIPT="
set terminal postscript eps enhanced color;
set output 'Observations-$INPUT_FILE.eps';
set title '$TITLE' font 'Helvetica,25';
set xlabel 'Simulation Time (sec)' font 'Helvetica,25';
set tics font 'Helvetica,15'
set y2tics mirror;
set ylabel '$YLABEL' font 'Helvetica,25';
plot $PLOT_CMD;
"
echo "$GNUPLOT_SCRIPT" | gnuplot

