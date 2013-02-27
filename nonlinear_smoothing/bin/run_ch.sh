#!/bin/bash

# run chambolle's algorithm
argc=$#
if [ $argc -eq 0 ]
then
  echo "usage: $0 in.png out.png iters threads"
  exit 1
fi

lambda=0.248  
tau=0.0001 # initial step size this will be update each dual step

echo "lambda: $lambda"
echo "tau: $tau"

in=$1
out=$2
iters=$3
flag=1
thread=$4

echo "./tv $in $out $lambda $tau $iters $thread $flag"
./tv $in $out $lambda $tau $iters $thread $flag 
