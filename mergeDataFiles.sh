#!/bin/bash

OUTFILE="$1"
FIRST_FILE="$2"
shift 2
FILES="$@"

count=1

echo "Output file: $OUTFILE"

echo "$count file: $FIRST_FILE"
cat "$FIRST_FILE" > "$OUTFILE"

for f in $FILES;
do
  let count=$count+1

  echo "$count file: $f"
	tail -n +2 $f >> "$OUTFILE"
done
