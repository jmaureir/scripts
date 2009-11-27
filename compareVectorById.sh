#!/bin/bash
#
# compare one vector data from two vector files
# 
# This script works together with the wrapper CompareAllVectors.sh
#
# Juan-Carlos Maureira

VECTOR=$1
FILE1=$2
FILE2=$3

DEF_LINE=`cat vector_defs.tmp | grep "vector $VECTOR "`
L1=`echo $DEF_LINE | awk '{print $3}'`
L2="ETV"
NAME=`echo $DEF_LINE | awk -v l1=$L1 -v l2=$L2 '{ v=index($0,l1)+length(l1)+1; e=length($0)-v-3; print substr($0,v,e) }'`
NAME=`echo $NAME | awk '{ gsub("\"","",$0); print }'`
MODULE="$L1"
echo "vector $VECTOR $NAME in module $MODULE"

OUT1=`mktemp`
OUT2=`mktemp`

cat $FILE1 | awk -v id=$VECTOR '{ if ($1 == id) print $3 " " $4 }' > $OUT1
cat $FILE2 | awk -v id=$VECTOR '{ if ($1 == id) print $3 " " $4 }' > $OUT2

RSCRIPT="
vector1 <- read.table('$OUT1');
vector2 <- read.table('$OUT2');

reg_time <- lm(vector1[,1] ~ vector2[,1]);
reg_value <- lm(vector1[,2] ~ vector2[,2]);
summary(reg_time);
summary(reg_value);

anova_time <- aov(vector1[,1] ~ vector2[,1]);
anova_value <- aov(vector1[,2] ~ vector2[,2]);

anova_time;
anova_value;

summary(anova_time);
summary(anova_value);
"
echo $RSCRIPT | R --no-save > "$NAME-$MODULE.anova"

rm $OUT1
rm $OUT2

exit 0
