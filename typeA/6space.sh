#!/bin/bash

file1="all6spaces.txt"
file2="alltxt6spaces.txt"
while IFS= read -r line1 && IFS= read -r line2 <&3; do
  sed -i "167s/.*/f = openOutAppend \"frobenius_output-$line2\";/" trial_frobenius.m2
  sed -i "3s/.*/f = open\(\'frobenius_output-$line2\'\, \'x\'\)/" pyfrob.py
  sed -i "6s/.*/with open\(\'Flags-In-6-Space\/$line1\/$line2\'\,\'r\'\) as input_file\:/" pyfrob.py
  mkdir Working-On-$line1
  python3 pyfrob.py
  mv frobenius_output-$line2 Flags-In-6-Space/$line1/
  rmdir Working-On-$line1
  
done < "$file1" 3< "$file2"
