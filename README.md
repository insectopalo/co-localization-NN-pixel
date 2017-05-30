The task consisted in finding the nearest neighbours for the pixels in the
input TIFF 1 from the input TIFF 2. The program assumes that the images have a
black baground (RGB=0,0,0) and that any deviation from that, is a positive
pixel. So, it really does not matter what the colour of the input images are,
as long as the background is black.

The pixelDistance script takes two arguments that correspond to the TIFF
filenames. The output of the script will be a line for each of the pixels of
the first image that are different from black. In each of these lines, there
are five fields separated by commas. The first four fields are the 0-based
coordinates of a pixel in input 1 and the nearest neighbour from input 2 (x y),
whereas the fifth field corresponds to the distance beetween them in pixel
units.

The program calculates all the distances in a pairwise manner, so it would be
extremely easy to change the code slightly to output an NxM matrix of distances
where N and M are the number of pixels different from black of the input 1 and
input 2 images, respectively. This would correspond to a complete bipartite
weighted graph. 

e.g.
python pixelDistance.py tif/1_green.tif tif/1_magenta.tif > results/complete.csv
