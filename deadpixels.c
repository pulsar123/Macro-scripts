#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <wand/MagickWand.h>

/*
  Part of Macro-scripts package (a complete Open Source workflow for processing macro focus stacking photographs)
  Written by Sergey Mashchenko
 
  Utilizes ImageMagick library.

  Program to find all hot and dead pixels in a given image (dark frame; gray scale).
  The dark frame should be generated as follows:

  dcraw -4 -T -j -t 0 -D dark.dng

  Compiling the program (Linux and Cygwin):

  gcc `Wand-config --cflags --cppflags` -O4 -o deadpixels deadpixels.c `Wand-config --ldflags --libs` -lm

*/


int main(int argc,char **argv)
{
#define ThrowWandException(wand) \
{ \
  char \
    *description; \
 \
  ExceptionType \
    severity; \
 \
  description=MagickGetException(wand,&severity); \
  (void) fprintf(stderr,"%s %s %lu %s\n",GetMagickModule(),description); \
  description=(char *) MagickRelinquishMemory(description); \
  exit(-1); \
}

  long
    y, Ntot;

  long
    k, Nx, Ny, Npix, Npix_old, Ndead, Nhot;

  MagickBooleanType
    status;

  MagickPixelPacket
    pixel;

  MagickWand
    *image_wand;

  PixelIterator
    *iterator;

  PixelWand
    **pixels;

  register long
    x;

  size_t
    width;

 FILE
   *fp;

 double
   sum, sum2, p0, sgm, p, Nsigma;
 
 // Threshold for dead pixels:
 const double
   dead = 1e-6;


  if (argc==1)
    {
      printf("Usage: %s  dark_frame  [Nsigma]\n",argv[0]);
      printf("If omitted, Nsigma=10\n\n");
      printf("Generate dark_frame using the following command:\n\n");
      printf("    dcraw -4 -T -j -t 0 -D raw_dark_frame\n\n");
      exit(0);
    }

  if (argc==3)
    Nsigma = atof(argv[2]);
  else
    Nsigma = 10;
  printf ("Nsigma=%f\n", Nsigma);

  /*
    Read the image.
  */


  MagickWandGenesis();
  image_wand=NewMagickWand();
  status=MagickReadImage(image_wand,argv[1]);
  if (status == MagickFalse)
    ThrowWandException(image_wand);

  // Image size:
  Nx = MagickGetImageWidth(image_wand);
  Ny = MagickGetImageHeight(image_wand);


  p0 = 0.0;
  sgm = 1e12;
  Npix = -1;
  Npix_old = -2;
  k = 0;

  // Iteratively computing sigma for dark frame pixels
  while (Npix != Npix_old)
      {
	k++;
	iterator=NewPixelIterator(image_wand);
	if ((iterator == (PixelIterator *) NULL))
	  ThrowWandException(image_wand);
	Npix_old = Npix;
	sum = 0.0;
	sum2 = 0.0;
	Npix = 0;
	for (y=0; y < (long) MagickGetImageHeight(image_wand); y++)
	  {
	    pixels=PixelGetNextIteratorRow(iterator,&width);
	    if ((pixels == (PixelWand **) NULL))
	      break;
	    for (x=0; x < (long) width; x++)
	      {

		PixelGetMagickColor(pixels[x],&pixel);
		p = pixel.green;

		// Discarding dead pixels, and using three sigma rule:
		if (p > dead && abs(p-p0)<3*sgm)
		  {
		    sum = sum + p;
		    sum2 = sum2 + p * p;
		    Npix++;
		  }
	      } // x cycle
	  } // y cycle

	p0 = sum / Npix; 
	sgm = sqrt(sum2/Npix - p0*p0);
	printf ("Iteration %d; p=%e, sgm=%e, N=%d\n", k, p0, sgm, Npix);

	if (y < (long) MagickGetImageHeight(image_wand))
	  ThrowWandException(image_wand);
	iterator=DestroyPixelIterator(iterator);
      }


  // Discovering all dead and hot pixels, and writing them to deadpixels.txt file
  fp = fopen("deadpixels.txt", "w");
  Ndead = 0;
  Nhot = 0;
  iterator=NewPixelIterator(image_wand);
  if ((iterator == (PixelIterator *) NULL))
    ThrowWandException(image_wand);
  for (y=0; y < (long) MagickGetImageHeight(image_wand); y++)
    {
      pixels=PixelGetNextIteratorRow(iterator,&width);
      if ((pixels == (PixelWand **) NULL))
	break;
      for (x=0; x < (long) width; x++)
	{

	  PixelGetMagickColor(pixels[x],&pixel);
	  p = pixel.green;

	  if (p < dead)
	    Ndead++;
	  if (p-p0 > Nsigma*sgm)
	    Nhot++;
	  
	  // Detecting dead and hot pixels:
	  if (p < dead)
	    {
	      // Dead pixels are marked with the timestamp=0
	      fprintf (fp, "%d %d 0\n", x, y);
	    }
	  else if (p-p0 > Nsigma*sgm)
	    {
	      // Hot pixels are marked with the timestamp=1 !!! removed this feature, as new dcraw dosn't work with this
	      fprintf (fp, "%d %d 0\n", x, y);
	    }
	} // x cycle
    } // y cycle
  if (y < (long) MagickGetImageHeight(image_wand))
    ThrowWandException(image_wand);
  iterator=DestroyPixelIterator(iterator);

  fclose(fp);

  printf("\n Ndead=%d\n Nhot=%d\n Ntotal=%d\n", Ndead, Nhot, Ndead+Nhot);

  image_wand=DestroyMagickWand(image_wand);

  MagickWandTerminus();
  return(0);
}

