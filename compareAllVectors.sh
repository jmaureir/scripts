#!/bin/bash
#
# compare two vec files from omnet++ 4.0
#

if [ "$1" == "" -o "$2" == "" ]
then
  echo "usage $0 file1.vec file2.vec"
  exit 1
fi

FILE1=$1
FILE2=$2

VECTORS=`cat $FILE1 | grep "vector" | awk '{ print $2 }'`
#VECTORS="1893"

cat $FILE1 | grep "vector "  > vector_defs.tmp

./distrun.sh -j 3 -v var="$VECTORS" -c ./compareVectorById.sh var "$FILE1" "$FILE2" 
