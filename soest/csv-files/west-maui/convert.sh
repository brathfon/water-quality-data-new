#!/bin/bash


for filename in ./*.csv
do
  part1=`echo $filename | cut -d "_" -f 1`
  part2=`echo $filename | cut -d "_" -f 2`
  part3=`echo $filename | cut -d "_" -f 3`

  month=${part2:0:2}
  day=${part2:2:2}
  year=${part2:4:2}
  
  echo Moving $filename to ${part1}_${year}${month}${day}_${part3}
  mv $filename ${part1}_${year}${month}${day}_${part3}
  
done