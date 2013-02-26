#!/bin/bash

# run chambolle's algorithm

lambda=0.248  #.0415 # .053 # .0485
tau=.2 #0.2 # = .2 + k*.08
#theta=0.833 # = (.5 + 5/(15+k))/tau

echo "lambda: $lambda"
echo "tau: $tau"

in=$1
out=$2
iters=$3
flag=1

./tv $in $out $lambda $tau $iters $flag
