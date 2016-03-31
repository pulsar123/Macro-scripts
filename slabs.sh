#!/bin/bash

# Focus stackin with enfuse using a two-stage process (first creating slabs, and then stacking the slabs)
# All files in the current directory with names OUT*.tif will be processed (output of Align.sh script)
# If any argument used, will skip the enfuse part (dry run; for debugging)

# Overlap on each side (fraction), for each slab:
over=0.3
# Overlap should be at least that many images:
Nover_min=2

/usr/bin/ls -1 OUT*.tif 2>/dev/null > List

# Number of input files:
N=`cat List|wc -l`
if test $N -eq 0
  then
  echo "No files to process; exiting"
  exit
  fi

N1=$(($N-1))

# Size of each slab (not including the overlap)
Size=`echo $N| awk '{print int(sqrt($1))}'`
# N overlap is at least $Nover_min:
Nover=`echo $Size $over $Nover_min|awk '{A=int($1*$2); if (A<$3) print $3; else print A; fi}'`

# Last (usually smaller) slab size:
Slast=$(($N%$Size-$Nover))
# Number of complete slabs:
Nslabs=$(($N/$Size))
if test $Slast -lt 0
  then
  Nslabs=$(($Nslabs-1))
  Slast=$(($N-$Nslabs*$Size-$Nover))
  fi

echo "Size=$Size, Nslabs=$Nslabs, Slast=$Slast, Nover=$Nover"
echo
j=0


# First stage (creating multiple slabs)
for ((i=0; i<$Nslabs; i++))
 do
# First file to include in the slab:
 k1=$(($i*$Size+$j))
 if test $j -lt $Slast
   then
   j=$(($j+1))
   fi
# Last file to include in the slab:
 k2=$((($i+1)*$Size+$j+$Nover-1))
 if test $k2 -gt $N1
   then
   k2=$N1
   fi
 echo Slab=$i, range $k1 - $k2, $(($k2-$k1+1)) frames
 K1=$(($k1+1))
 K2=$(($k2+1))
 if test $# -eq 0
   then
   enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 --hard-mask --gray-projector=l-star --output=`printf '%04d' $i`.tif `cat List | sed -n ${K1},${K2}p`
   fi
 done


#  Second stage - merging all slabs into final stacked photo
 echo
 echo "Second stage: stacking the slabs"
 if test $# -eq 0
   then
   enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 --hard-mask --gray-projector=l-star --output=output.tif ????.tif
   fi
