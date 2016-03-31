#!/bin/bash
# Bash script to generate deadpixels.txt file (list of coordinates for all dead and hot pixels) using provided dark frame.

echo
if test $# -ne 1
 then
 echo "Syntax: Deadpixels.sh dark_frame_raw_image" 
 echo
 exit
 fi

# Converting raw dark frame to 16-bit gray scale TIFF (linear color space):
dcraw -4 -T -j -t 0 -D -c $1 > dark.tiff

# Using deadpixels.exe program to find all dead and hot pixels (using Nsigma=10):
deadpixels.exe dark.tiff 10

# Deleting dark.tiff file:
\rm dark.tiff

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
