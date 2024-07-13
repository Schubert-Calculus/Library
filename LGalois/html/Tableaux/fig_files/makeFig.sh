#!/bin/sh
cat partitions |
while read u 
do
 echo "P:=$u:" | cat > temp
 maple -c "read(temp)" -q makeTableau.fig.maple
done
rm -f temp
