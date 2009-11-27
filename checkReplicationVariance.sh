#!/bin/sh
#
# Depends on gplots in R
#

INPUT_FILE=$1
EXPERIMENT=$2

cat "$INPUT_FILE" | grep "$EXPERIMENT" > "/tmp/$EXPERIMENT.tmp"

RSCRIPT="
library(gplots);
data <- as.matrix(read.table('/tmp/$EXPERIMENT.tmp'));
data.replicas <- as.factor(data[,2]) ;
data.obs <- as.numeric(data[,4]);

anova <- aov(data.obs ~ data.replicas);
mrt <- TukeyHSD(anova, \"data.replicas\");

summary(anova);
mrt;

pdf(file = 'TukeyHSD-$EXPERIMENT-$INPUT_FILE.pdf', width=5, height=5);
plot(mrt);
dev.off();
"
echo $RSCRIPT | R --no-save > "$INPUT_FILE-$EXPERIMENT.anova"
rm -rf "/tmp/$EXPERIMENT.tmp"
