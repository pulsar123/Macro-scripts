#!/bin/bash
# Unsharp masking for macro shots, using three different unsharp scales

# Radii for the three scales (pixels):
rad_x=24
rad_y=6
rad_z=0.5
# Default strength for each scale:
s_x=0.075
s_y=0.1
s_z=4

echo
if test $# -eq 0
 then
 echo "Syntax:  unsharp.sh  [strength]  in_file  out_file"
 echo
 echo "If 'strength' is skipped, it is assumed to be 1."
 echo "If 'strength' is a single number, all spatial scales will be sharpened by the same amount (given by that number)."
 echo "If 'strength' has the following form - x:y:z - the largest scale will be sharpened using 'x' strength,"
 echo "  the middle scale will use 'y', and the smallest scale will use 'z'."
 echo
 exit
fi

if test $# -eq 2
 then
  x=1
  y=1
  z=1
  IN="$1"
  OUT="$2"
 else
  IN="$2"
  OUT="$3"
  N=`echo $1 |grep : |wc -l `
  if test $N -eq 0
   then
    x=$1
    y=$1
    z=$1
   else
    x=`echo $1 | cut -d: -f1`
    y=`echo $1 | cut -d: -f2`
    z=`echo $1 | cut -d: -f3`
   fi
 fi 

echo "Using the large/middle/small scale sharpening strengths $x, $y, $z"
echo

# Unsharp masking, done in the following order: large scale, middle scale, small scale:
convert "$IN" -unsharp 0x$rad_x+`echo $x $s_x | awk '{print $1*$2}'`+0 -unsharp 0x$rad_y+`echo $y $s_y | awk '{print $1*$2}'`+0 -unsharp 0x$rad_z+`echo $z $s_z | awk '{print $1*$2}'`+0 "$OUT"


