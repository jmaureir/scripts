#!/bin/sh

export INETMANET=../../inetmanetAlfonso
export IEEE80211MGMT=../../Ieee80211MgmtStack

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INETMANET/src/inet:$IEEE80211MGMT/Ieee80211MgmtStack
export TMP=/home/jcmaurei/tmp
export TEMP=$TMP
export TEMPDIR=$TMP

#MODELS="Model1 Model2 Model3 Model2A Model2B Model3A Model3B"
MODELS="Model2A Model3A"

for m in $MODELS;
do
        LOGFILE="$m.log"
        opp_runall -j2 ../RobustNetwork -u Cmdenv -c $m -n .:../src:$INETMANET/examples:$INETMANET/src:$IEEE80211MGMT/nodes:$IEEE80211MGMT/src -l $INETMANET/src/inet -l $IEEE80211MGMT/Ieee80211MgmtStack --record-eventlog=false --debug-on-errors=false -r 0..5 > $LOGFILE
done

