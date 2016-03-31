#!/bin/bash
# Part of Macro-scripts package (a complete Open Source workflow for processing macro focus stacking photographs)
# Written by Sergey Mashchenko

# Bash script to convert raw images (CR2, DNG etc.) to 48-bit TIFF images.
# It can use either sRGB or linear color space, and can optionally accept custom white balance coefficients 
# (computed by applying another script - WB.sh - to a raw photograph of a gray card).

if test $# -lt 2
 then
 echo
 echo "Syntax:"
 echo "  RAW_convert.sh [-l] [-r <r g b g>] image1 [image2 image3 ...]"
 echo
 echo "-l: use linear color space"
 echo "-r <r g b g>: use custom white balance coefficients r, g, b, g"
 echo
 exit
 fi

# Processing optional switches
args=("$@")
arg_r=-1
arg_l=-1
for i in 0 1 5
 do
 if test "${args[$i]}" = "-l"
   then
   arg_l=$i
   fi
 if test "${args[$i]}" = "-r"
   then
   arg_r=$i
   fi
 done

if test $arg_l -ge 0
 then
 echo "Using linear color space"
 OPT="-4"
 else
 echo "Using sRGB color space"
 OPT="-6 -W"
 fi

if test $arg_r -ge 0
 then
 echo "Using custom white balance"
 OPT2="${args[$arg_r]} ${args[$(($arg_r+1))]}  ${args[$(($arg_r+2))]} ${args[$(($arg_r+3))]} ${args[$(($arg_r+4))]}"
 else
 echo "Using system white balance"
 OPT2=""
 fi

if test $arg_l -ge 0
 then
 shift
 fi
if test $arg_r -ge 0
 then
 shift 5
 fi

# Copying the deadpixels.txt file if present:
if test -f ~/deadpixels.txt
  then
  \cp ~/deadpixels.txt .
  dead_arg="-P deadpixels.txt"
  else
  dead_arg=""
  fi

# RAW images conversion to 48-bit TIFFs:
dcraw -v $dead_arg $OPT $OPT2 -T $*

echo
echo "Success!"
echo
