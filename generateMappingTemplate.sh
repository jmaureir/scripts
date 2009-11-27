#!/bin/bash

DATAFILE="$1"

TMP=`mktemp`

tail -n +2 "$DATAFILE" | awk '{ print $3 }' >> $TMP

MODULES=`cat $TMP | sort | uniq`


while [[ $1 ]]
do
	shift
	REGEX=`echo $1 | cut -d= -f 1`
	REPL=`echo $1 | cut -d= -f 2`

	for m in $MODULES;
	do
		if [[ $m =~ $REGEX ]]; then
			n=${#BASH_REMATCH[*]}
			i=1
			R=$REPL
			while [[ $i -lt $n ]]
			do
				 R=`echo "$R" | sed -e '${s/#'$i'/'${BASH_REMATCH[$i]}'/g}'`
				 let i++
			done
      if [ "$R" != "" ]
			then
				echo "$m $R"
			fi
		fi
	done
done
rm $TMP
