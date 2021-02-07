#!/bin/bash
# Part of Macro-scripts package (a complete Open Source workflow for processing macro focus stacking photographs)
# Now works with either single or multiple dark frames. When multiple images are provided, they are averaged first (written as dark.tiff file).
# Written by Sergey Mashchenko

# Bash script to generate deadpixels.txt file (list of coordinates for all dead and hot pixels) using provided dark frame.

N=$#

echo
if test $N -eq 0
 then
 echo "Syntax: Deadpixels.sh dark_frame_raw_image[s]" 
 echo
 exit
 fi

rm -f dark_*.tiff

for ((i=0; i<$N; i++))
 do
 # Converting raw dark frame(s) to 16-bit gray scale TIFF (linear color space):
 echo "Converting $1"
 dcraw -4 -T -j -t 0 -D -c $1 > dark_${i}.tiff
 shift
 done
 
if test $N -eq 1
 then
 \mv dark_0.tiff dark.tiff
 else
 # If multiple dark frame provided, averaging them using ImageMagick:
 magick convert dark_*.tiff -evaluate-sequence mean dark.tiff 
 fi

# Using deadpixels program to find all dead and hot pixels (using Nsigma=10):
# Reduce Nsigma if not all hot pixels are detected (but don't make it smaller than 5.5)
# Increase Nsigma if spurious hot pixels are detected (but likely the problem is that your dark frame is not
# entirely dark)
deadpixels dark.tiff 4


if test -f ~/deadpixels.txt
 then
 echo
 echo "~/deadpixels.txt already exists."
 echo "Do you want to overwrite it (y/n)?"
 read p
 if test "$p" = "y" -o "$p" = "Y"
   then
# Copying the deadpixels.txt file to home directory (overwriting the old file present there):
   \cp deadpixels.txt ~
   fi
 fi
