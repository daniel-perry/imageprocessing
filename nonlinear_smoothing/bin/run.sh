#!/bin/bash

lambda=.0415 # .053 # .0485
tau=0.2 # = .2 + k*.08
#theta=0.833 # = (.5 + 5/(15+k))/tau

in=$1
out=$2
iters=$3
flag=$4

./tv $in $out $lambda $tau $iters $flag