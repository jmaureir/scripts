#!/bin/bash
#
# Generate a means plot from a data file.
# Depends on gplots in R and gplots library
#
# Arguments:
#  1. Input data file (first line must be column headers)
#  2. Factors: the factors to compare (Experiments, Replicas, etc)
#  3. Observations: the values to compute the means plot
#
# @author: Juan-Carlos Maureira
# INRIA 2009

if [ $# != 3 ]
then
   echo "usage: $0 inputfile.data factors observations"
   exit 1
fi

INPUT_FILE=$1
FACTORS=$2
RESPONSE_VAR=$3

RSCRIPT="
library(gplots);
data <- as.matrix(read.table('$INPUT_FILE', header = T));
data.experiment <- as.factor(data[,\"$FACTORS\"]) ;
data.obs <- as.numeric(data[,\"$RESPONSE_VAR\"]);
pdf(file = 'MeansPlot-$INPUT_FILE.pdf', width=5, height=5);
plotmeans(data.obs ~ data.experiment,xlab='$FACTORS', p=0.95, ylab='$RESPONSE_VAR',connect=FALSE,n.label=FALSE,main=c('Means Plot for \\n$INPUT_FILE'),digits=8);
dev.off();
"
echo $RSCRIPT | R --no-save
