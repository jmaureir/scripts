#!/bin/bash

function splitVector() {
  VECTOR_NAME=$1
  MODELS=$2 

  for m in $MODELS;
  do
    ./splitVectorsFromExperiment.sh $m "$VECTOR_NAME" "winavg(100)"
  done

  return 0
}

function getScalar() {

  if [ -z "$1" ]
  then
    return 0
  fi

  SCALAR_NAME=$1
  MODELS=$2
  FILTER=$3
  SCALAR_LABEL=$4

  if [ -z "$SCALAR_LABEL" ]
  then
   SCALAR_LABEL="$1"
  fi

  echo "$FILTER" | while read f
  do
    FIL=`echo "$f" | cut -d, -f1`
    LAB=`echo "$f" | cut -d, -f2`
    if [ "$FIL" != "" ] 
    then
      for m in $MODELS;
      do
        echo "processing $SCALAR_NAME ($SCALAR_LABEL) $m $LAB"
        ./getScalarFromExperiment.sh "$m" "$SCALAR_NAME" "$FIL" "$m-$SCALAR_LABEL-$LAB"
      done
    fi
  done
  return 0
}

function getStatistic() {

  if [ -z "$1" ]
  then
    return 0
  fi


  STAT_NAME="$1"
  MODELS="$2"
  FILTER="$3"
  STAT_LABEL="$4"

  if [ -z "$STAT_LABEL" ]
  then
   STAT_LABEL="$1"
  fi

  if [ -z "$FILTER" ]
  then
    FILTER="all,all"
  fi

  echo "$FILTER" | while read f
  do
   
    FIL=`echo "$f" | cut -d, -f1`
    LAB=`echo "$f" | cut -d, -f2`
    for m in $MODELS;
    do
      echo "processing $STAT_NAME ($STAT_LABEL) $m $LAB"
      ./getStatisticsFromExperiment.sh "$m" "$STAT_NAME" "split" "$m-$STAT_LABEL-$LAB"
    done
  done
  return 0
}

# Vectors
# "average bandwidth from Robust.sw_hosts"  
# "current bandwidth from Robust.sw_gw"  
# "average bandwidth from Robust.sw_gw"  
# "current bandwidth from Robust.sw_hosts"

# Scalars

SCALARS="
numGivenUp
numCollision
numRetry
numSent
numSentWithoutRetry
numReceived
numReceivedOther
" 

SCALARS1="
bits/sec rcvd,bpsRcvd
bits/sec sent,bpsSent
" 

# Statistics
STATS="
Ping roundtrip delays,PingRTT
"

# filters 
FILTER="
*.AccessPoint*,AccessPoint
*.Gateway*,Gateway
"

FILTER1="
*.server[*].*,server
"

MODELS="Model1 Model2 Model3 Model2A Model2B Model3A Model3B"

#splitVector "average bandwidth from Robust.sw_hosts" "$MODELS"  
#splitVector "current bandwidth from Robust.sw_gw" "$MODELS" 
#splitVector "average bandwidth from Robust.sw_gw" "$MODELS" 
#splitVector "current bandwidth from Robust.sw_hosts" "$MODELS" 

#echo "$SCALARS" | while read s
#do
#   echo "processing $s"
#   getScalar "$s" "$MODELS" "$FILTER" > out-scalars.tmp
#done

#echo "$SCALARS1" | while read s
#do
#
#   SCA=`echo $s | cut -d, -f1`
#   LAB=`echo $s | cut -d, -f2`

#   echo "processing $SCA ($LAB)"
#   getScalar "$SCA" "$MODELS" "$FILTER1" "$LAB" > out-scalars.tmp
#done


echo "$STATS" | while read s
do

   STA=`echo $s | cut -d, -f1`
   LAB=`echo $s | cut -d, -f2`

   if [ "$STA" != "" ]
   then
     echo "processing $STA ($LAB)"
     getStatistic "$STA" "$MODELS" "all" "$LAB" 
   fi
done

