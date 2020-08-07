#!/bin/bash


for file in `ls *.csv`
do
  echo "file $file"
  cat $file | tr -s '\015' '\012' > /tmp/doit.txt
  cp /tmp/doit.txt $file
done