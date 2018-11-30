#!/bin/bash

echo
echo -e "\e[42mRANDOM 4K BLOCKS\e[0m"
echo "- Write:"
dd if=/dev/zero of=./random bs=4K count=64K oflag=dsync 2> >(awk '/bytes/{print $(NF-1), $NF}') &&

echo
echo "Dropping cache..."
sync; echo 3 > /proc/sys/vm/drop_caches & wait

echo
echo "- Read:"
dd if=./random of=/dev/null bs=4K count=64K 2> >(awk '/bytes/{print $(NF-1), $NF}') &&
rm ./random

echo
echo -e "\e[42mSEQUENTIAL\e[0m"
echo "- Write:"
dd if=/dev/zero of=./seq bs=1G count=1 oflag=dsync 2> >(awk '/bytes/{print $(NF-1), $NF}') &&

echo
echo "Dropping cache..."
sync; echo 3 > /proc/sys/vm/drop_caches & wait

echo
echo "- Read:"
dd if=./seq of=/dev/null bs=1G count=1 2> >(awk '/bytes/{print $(NF-1), $NF}') &&
rm ./seq

echo
echo -e "\e[42mRANDOM 4K BLOCKS PARALLEL(64)\e[0m"
echo "- Write:"

STR="{ "
for((i=0; i<64; i++))
do
        STR+="dd if=/dev/zero of=./parallel bs=4K count=1K skip=$i"K" seek=$i"K" & "
done
STR+="wait; }"

eval $STR 2> >(awk '/bytes/{print $(NF-1), $NF}' > output.txt)

awk '{sum+=$1} END {print sum, "MB/s"}' ./output.txt
rm ./output.txt
rm ./parallel

echo
echo "Dropping cache..."
sync; echo 3 > /proc/sys/vm/drop_caches & wait

echo
echo "- Read:"

STR2="{ "

for((i=0; i<64; i++))
do
        STR2+="dd if=./parallel of=/dev/null bs=4K count=1K skip=$i"K" seek=$i"K" & "
done
STR2+="wait; }"

eval $STR 2> >(awk '/bytes/{print $(NF-1), $NF}' > output.txt)

awk '{sum+=$1} END {print sum, "MB/s"}' ./output.txt
rm ./output.txt
rm ./parallel
