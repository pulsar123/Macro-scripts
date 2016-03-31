#!/bin/bash
# Part of Macro-scripts package (a complete Open Source workflow for processing macro focus stacking photographs)
# Written by Sergey Mashchenko

# Bash script to compute white balance settings for dcraw, using central area in a raw grey card image

if test $# -ne 1
 then
 echo
 echo "Syntax:  WB.sh  grey_card_raw_image"
 echo
 exit
 fi

# Fraction of the image to use for white balance calculations (in both dimensions; centered)
frac=0.3

# Copying the deadpixels.txt file if present:
if test -f ~/deadpixels.txt
  then
  \cp ~/deadpixels.txt .
  dead_arg="-P deadpixels.txt"
  else
  dead_arg=""
  fi

# Obtaining the image dimensions:
read Nx Ny <<< $(dcraw -i -v $1 |grep "^Image size"|cut -d: -f2|sed 's/x//g')
# Center coordinates:
x=$(($Nx/2))
y=$(($Ny/2))
# Crop dimensions:
w=`echo $x $frac | awk '{print int($1*$2)}'`
h=`echo $y $frac | awk '{print int($1*$2)}'`

echo
echo "Image dimensions: $Nx x $Ny"
echo "Crop area center and dimensions: x,y=$x,$y; w,h=$w x $h"
echo

# Computing white balance
wb=`dcraw $dead_arg -v -A $x $y $w $h -c $1 2>&1 >/dev/null | grep "^multipliers" | cut -d" " -f2-`

echo "White balance (arguments for -r switch of dcraw):"
echo $wb
echo
