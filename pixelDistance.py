#!/usr/bin/env python


from __future__ import print_function

import sys
import numpy as np
import math
from PIL import Image
#import re
#import operator
#import csv

# Check that enough arguments are provided in the command line
if len(sys.argv) != 3:
    sys.exit("USAGE: " + sys.argv[0] + " <matrix1> <matrix2>")

# Get filename from command line
tiffFileName1 = sys.argv[1]
tiffFileName2 = sys.argv[2]



# Get coordinates TIFF 1
im1 = Image.open(tiffFileName1)
imMat1 = np.array(im1)
binMat1 = np.sum(imMat1, axis=2)

# Get coordinates TIFF 2
im2 = Image.open(tiffFileName2)
imMat2 = np.array(im2)
binMat2 = np.sum(imMat2, axis=2)

coords1 = list()

for x in range(0, binMat1.shape[0]):
    for y in range(0, binMat1.shape[1]):
        if binMat1[x,y] != 0:
            coords1.append([x,y])

coords2 = list()

for x in range(0, binMat2.shape[0]):
    for y in range(0, binMat2.shape[1]):
        if binMat2[x,y] != 0:
            coords2.append([x,y])




# Calculate distances among each pair of positive values

dist = np.zeros((len(coords1),len(coords2)))

for i, p1 in enumerate(coords1):
    for j, p2 in enumerate(coords2):
        dist[i,j] = math.sqrt(abs(p1[0]-p2[0])**2 + abs(p1[1]-p2[1])**2)
        



# Get the nearest neighbour of each row

indices = np.argmin(dist, axis=1)



# Print out a list of nearest neighbours for each ON pixel of input1
# Note that x and y are swapped

print("#X1,Y1,X2,Y2,dist", file=sys.stdout)
for i, index in enumerate(indices):
    print("{x1},{y1},{x2},{y2},{dist}".format(x1=coords1[i][1], y1=coords1[i][0], dist=dist[i][index], x2=coords2[index][1], y2=coords2[index][0]), file=sys.stdout)

