#!/bin/sh
#
# Split a input data file extracting a given list of replicas.
# arguments:
#  1. Experiment Name: the basename of the vectors file to be processed.
#  2. Replica List: the list of replicas you want to extract
#  3. Input data file : the input data file (in quotes)
#  4. Output data file : the output data file to be generated (in quotes)
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

if [ $# != 5 ]
then
  echo "usage: $0 Experiment \"replica list\" \"input.data\" \"output.data\""
  echo ""
  exit 1
fi

EXPERIMENT="$1"
REPLICAS="$2"  

INPUT_DATA="$3"
OUTPUT_FILE="$4"

red='\E[31;47m'
alias resetColors="tput sgr0"

if [ $# != 4 ]
then
   echo "usage: $0 Experiment \"Replica List\" \"Input File\" OutputFile"
   exit 0
fi

if [ -f "$INPUT_DATA" ]
then
   WITH_HEADER="no"
   if [ -f "$OUTPUT_FILE" ]
   then
      echo "Output file $OUTPUT_FILE already exists. Add the selected experiment/replicas at the end?"
      read yn
      case ${yn} in n|N|NO|No)
        echo -e "${red}removing the file $OUTPUT_FILE"
        tput sgr0
        rm  $OUTPUT_FILE
        WITH_HEADER="yes"
        ;;
      *)
        echo "Adding the experiment/replicas at the end..."
       ;;
      esac
   else
      WITH_HEADER="yes"
   fi

   if [ "$WITH_HEADER" == "yes" ] 
   then
      HEADER=`head -n 1 "$INPUT_DATA"`
      echo "$HEADER"  > $OUTPUT_FILE
   fi
   for replica in $REPLICAS
   do
     cat "$INPUT_DATA" | grep "$EXPERIMENT $replica" >> "$OUTPUT_FILE"
   done
   echo "done"
else
   echo "Input data file does not exist!."
fi
