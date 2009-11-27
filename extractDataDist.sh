#!/bin/bash

function splitVector() {
  VECTOR_NAME="$1"
  MODELS="$2"

  # ../distrun.sh -j 7 -v var="$MODELS" -c ../splitVectorsFromExperiment.sh var "\"$VECTOR_NAME\"" "\"winavg(100)\""
  ../getDataFromReplicatedVector.sh "$VECTOR_NAME"

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
        ../getScalarFromExperiment.sh "$m" "$SCALAR_NAME" "$FIL" "$m-$SCALAR_LABEL-$LAB"
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
      ../getStatisticsFromExperiment.sh "$m" "$STAT_NAME" "split" "$m-$STAT_LABEL-$LAB"
    done
  done
  return 0
}

#VECTORS="
#average bandwidth from Robust.sw_hosts
#current bandwidth from Robust.sw_gw
#average bandwidth from Robust.sw_gw
#current bandwidth from Robust.sw_hosts
#PingRTT
#smoothed RTT
#"

VECTORS="
average bandwidth from Robust.sw_gw
current bandwidth from Robust.sw_hosts
pingRTT
smoothed RTT
pingDrop
"

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
packets received by queue,mgmtQueuePktRcvd
packets dropped by queue,mgmtQueuePktDroped
Pings dropped,PingDropped
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

#MODELS="Model1 Model2 Model3 Model2A Model2B Model3A Model3B"
MODELS="Model1 Model2 Model3"

echo "Vectors"
echo "$VECTORS" | while read v
do
   if [ "$v" != "" ]
   then
     echo " processing $v"
     splitVector "$v" "$MODELS" 
   fi
done

echo "Scalars"

echo "$SCALARS" | while read s
do
   echo " processing $s"
   getScalar "$s" "$MODELS" "$FILTER" > out-scalars.tmp
done

echo "$SCALARS1" | while read s
do

   SCA=`echo $s | cut -d, -f1`
   LAB=`echo $s | cut -d, -f2`

   echo " processing $SCA ($LAB)"
   getScalar "$SCA" "$MODELS" "$FILTER1" "$LAB" > out-scalars.tmp
done

echo "Statistics"

echo "$STATS" | while read s
do

   STA=`echo $s | cut -d, -f1`
   LAB=`echo $s | cut -d, -f2`

   if [ "$STA" != "" ]
   then
     echo " processing $STA ($LAB)"
     getStatistic "$STA" "$MODELS" "all" "$LAB" 
   fi
done

