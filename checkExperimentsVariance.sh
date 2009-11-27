#!/bin/bash
#
# Make an ANOVA between experiements and the observations.
# Depends on gplots in R and gplots library
#
# Arguments:
#  1. Input data file (first line must be column headers)
#
# @author: Juan-Carlos Maureira
# INRIA 2009

if [ $# != 1 ]
then
   echo "usage: $0 inputfile.data"
   exit 1
fi

INPUT_FILE=$1

RSCRIPT="
library(gplots);
data <- as.matrix(read.table('$INPUT_FILE',header = T));
data.experiment <- as.factor(data[,1]) ;
data.replicas <- as.factor(data[,2]) ;
data.obs <- as.numeric(data[,4]);

anova <- aov(data.obs ~ data.experiment);
mrt <- TukeyHSD(anova, \"data.experiment\");

summary(anova);
mrt;

pdf(file = 'TukeyHSD-$INPUT_FILE.pdf', width=5, height=5);
plot(mrt);
dev.off();
"
echo $RSCRIPT | R --no-save > "$INPUT_FILE.anova"
