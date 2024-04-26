#!/bin/bash
declare -i begin=0
declare -i end=3
while [ $begin -le $end ]; do
 Singular -q G33.42.sing>> G33.42.output
 let begin=begin+1
done
