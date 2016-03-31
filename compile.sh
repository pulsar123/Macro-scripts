#!/bin/bash

if test ! -f deadpixels -a ! -f deadpixels.exe
  then
  echo "Compiling deadpixels..."
  gcc `Wand-config --cflags --cppflags` -O4 -o deadpixels deadpixels.c `Wand-config --ldflags --libs` -lm
  fi

if test ! -f dcraw -a ! -f dcraw.exe
  then
  echo "Compiling dcraw..."
  gcc -DNO_JASPER -o dcraw -O4 dcraw.c -lm -ljpeg -llcms2
  fi
