#!/bin/bash

if [ ! -d $1 ] || [ ! -d $2 ];
then
    echo Input or Output directory are not fine
    exit 1
fi
if [ ! $3 -gt 0 ] || [ ! $4 -gt 0 ];
then
    echo Number of threads or buckets is incorrect 
    exit 1
fi

declare -i m
let m=$3+1

for input in $1/*
do
    file_name=$(basename $input .txt)

    for i in $(seq 1 $m)
    do
        echo input_file = $file_name ​NumThreads =​$i
        ./tecnicofs-mutex $input $2/$file_name-$i.txt $i $i
        echo
    done
done
