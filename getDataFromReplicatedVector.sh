#!/bin/bash

VECTOR_DIRNAME="$1"

if [ -d "$VECTOR_DIRNAME" ]
then
	find "$VECTOR_DIRNAME"/*.vec | while read file
  do
    # remove the vector name (directory)
    VECT_FILE=`echo "$file" | cut -d\/ -f 2`

		export VECTOR_FILE_ID=`echo "$VECT_FILE" | cut -d. -f 1 | awk -F- '{ print $(NF) }'`
		export REPLICA_ID=`echo "$VECT_FILE" | cut -d. -f 1 | awk -F- '{print $(NF-1) }'`
		export EXPERIMENT=`echo "$VECT_FILE" | cut -d. -f 1 | awk -v Repl=$REPLICA_ID -v Vect=$VECTOR_FILE_ID '{ sub("-"Repl"-"Vect,"",$0);print }'`
		export VECTOR_NAME=`head -n 1 "$file" | cut -d\" -f 2`
		export MODULE=`head -n 1 "$file" | cut -d' ' -f 4`

		echo "procesing $file, Module: $MODULE VectorName: $VECTOR_NAME Experiment $EXPERIMENT"

		OUTPUT_FILE="$VECTOR_NAME-$MODULE.data"
	
		if [ ! -f "$OUTPUT_FILE" ]
		then
			echo "Experiment Replica Time Obs" > "$OUTPUT_FILE"
		fi
		tail -n +5 "$file" | gawk -F, '{print ENVIRON["EXPERIMENT"],ENVIRON["REPLICA_ID"],$1,$2}' >> "$OUTPUT_FILE"
  done
else
  echo "usage: $0 {vector_name}"
	echo "Vector name must be a directory containing one single vector file for each replica"
fi

