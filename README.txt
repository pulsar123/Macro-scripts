Author: Sergey Mashchenko

A set of bash scripts for post-processing of focus stacks for macro photography. Utilizes open source programs
dcraw (https://www.cybercom.net/~dcoffin/dcraw/), Hugin (http://hugin.sourceforge.net/), and 
ImageMagick (http://www.imagemagick.org/script/index.php). Contains one C++ program written by the author (deadpixels.c).

The scripts use BASH shell, so should work under any Linux distro and Cygwin under Windows.

Assuming the directory Macro_scripts is located in your home directory, put the following line at the end of your ~/.bashrc file:

 export PATH=~/Macro-scripts-master:$PATH

For Cygwin (under Windows), you will need to install additional packages, including gcc-core, gcc-g++, libgcc1, ImageMagick,
all libMagick* modules, liblcms2 and liblcms2-devel, libjpeg and libjpeg-devel. Install the Windows binary of Hugin, and
add the Cygwin path to the Windows binary at the end of ~/.bashrc file, e.g.:

 export PATH=/cygdrive/c/Program\ Files/Hugin/bin/:$PATH

To compile the two executables (dcraw and deadpixels), execute the script compile.sh (for both Linux and Cygwin).

For more details, consult the wikia page:

http://pulsar124.wikia.com/wiki/Open_Source_workflow_for_macro_focus_stacking

