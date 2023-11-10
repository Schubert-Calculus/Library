#!/bin/bash
# Will create a directory containing subdirectories for each (partial) flag manifold in n-space.

# First, user inputs the n for the particular n-space they care about.
read -p "You want to create flags in n-space for what n? " n

# Make a directory called Flags-In-n-Space where the subdirectories will live.
mkdir Flags-In-$n-Space

sed -i "1s/.*/N = $n/" createflags.m2
M2 createflags.m2

file1="allconflags.txt"
file2="allbrackflags.txt"
while IFS= read -r line1 && IFS= read -r line2 <&3; do
  mkdir Flags-In-$n-Space/$line1
  sed -i "26s/.*/FlagManifold:=$line2;/" GenerateProblems.maple
  maple GenerateProblems.maple
  rm -rf $line1
#  sed -i "167s/.*/inputfile = get \"$line1.txt\";/" frobenius_trial.m2
#  sed -i "172s/.*/f = \"frobenius_output-$line1.txt\" << \"\";/" frobenius_trial.m2
#  M2 frobenius_trial.m2
  mv $line1.txt Flags-In-$n-Space/$line1/
#  mv frobenius_output-$line1.txt Flags-In-$n-Space/$line1/

done < "$file1" 3< "$file2"

rm allconflags.txt
rm allbrackflags.txt
