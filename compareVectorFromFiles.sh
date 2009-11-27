#!/bin/bash
#
# compare one two sequences of data (two columns) from 2 files
# and reports the anova and the regresion between both.
#
# Juan-Carlos Maureira

FILE1=$1
FILE2=$2

echo "vector $FILE1 with $FILE2"

RSCRIPT="
vector1 <- read.table('$FILE1');
vector2 <- read.table('$FILE2');

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
echo $RSCRIPT | R --no-save 

exit 0
