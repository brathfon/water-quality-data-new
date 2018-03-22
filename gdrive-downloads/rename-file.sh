#!/bin/bash


for file in *.tsv
do

  echo "File $file"
  newFile=`echo "$file" | sed 's/Hui o ka Wai Ola Data Entry - //g' | sed 's/ /-/g'`
  echo "moving $file to $newFile"
  mv "$file" $newFile

done

exit 0
