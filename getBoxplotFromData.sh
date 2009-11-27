#!/bin/bash
#
# Generate a box plot from a data file.
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
data <- as.matrix(read.table('$INPUT_FILE', header = T));
data.factors <- as.factor(data[,\"$FACTORS\"]) ;
data.response <- as.numeric(data[,\"$RESPONSE_VAR\"]);
pdf(file = 'BoxPlot-$INPUT_FILE.pdf', width=5, height=5);
boxplot(split(data.response,data.factors),xlab='$FACTORS', ylab='$RESPONSE_VAR',main=c('Boxplot for \\n$INPUT_FILE'));
stripchart(split(data.response,data.factors),method=\"jitter\",jitter=.05,vertical=T,add=T);
dev.off();
"
echo $RSCRIPT | R --no-save
