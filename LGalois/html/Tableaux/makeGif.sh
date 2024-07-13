#!/bin/sh
cat fileNames |
while read u
do
  fig2dev -L gif -m 0.5  fig_files/$u.fig $u.gif
done
