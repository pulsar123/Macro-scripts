#!/bin/bash

# Aligning focus stack, starting from the middle frame, and running two processes in parallel in the opposite directions.
# If something goes wrong you might need to kill one or both running align_image_stack processes manually.

echo
if test $# -lt 2
 then
 echo "Syntax:  Align.sh [-l] image1 image2 [image3 ...]"
 echo
 echo -l: assume that the images have linear color space
 echo
 exit
 fi

if test "$1" = "-l"
 then
 echo "Assuming linear color space"
 OPT="$1"
 else
 OPT=""
 fi

files=("$@")
N=$#
middle=$(($N / 2 - 1))
echo N=$N, middle=$middle
echo

# Reversing the order of files in the first half:
for e in "${files[@]:0:$middle+1}"
  do
    revfiles=( "$e" "${revfiles[@]}" )
  done

# First half:  &>out1.log &
align_image_stack "$OPT" --use-given-order -m -a P1_ ${revfiles[@]} &>out1.log &

# A 10s delay, to have a phase shift between two parallel processes:
sleep 10

# Second half:
align_image_stack "$OPT" --use-given-order -m -a P2_ ${files[@]:$middle} &>out2.log &

# Waiting for both processes to finish:
wait

# Renaming the outputs to become a single aligned stack
# Deleting the first file in the second half as it is identical to the last file in the first half:
\rm P2_0000.tif

for name in P1_*
 do
 N1=`echo $name |cut -b 4-7`
 N2=`echo $middle $N1 | awk '{printf "%04d\n", $1-$2}'`
 mv $name OUT${N2}.tif
 done

for name in P2_*
 do
 N1=`echo $name |cut -b 4-7`
 N2=`echo $middle $N1 | awk '{printf "%04d\n", $1+$2}'`
 mv $name OUT${N2}.tif
 done


