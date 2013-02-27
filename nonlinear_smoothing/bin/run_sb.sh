#!/bin/bash

# run split-bregman algorithm
argc=$#
if [ $argc -eq 0 ]
then
  echo "usage: $0 in.png out.png iters threads"
  exit 1
fi

mu=0.1 

echo "mu: $mu"

in=$1
out=$2
iters=$3
flag=2
thread=$4
ignore=1

echo "./tv $in $out $mu $ignore $iters $thread $flag"
./tv $in $out $mu $ignore $iters $thread $flag 
