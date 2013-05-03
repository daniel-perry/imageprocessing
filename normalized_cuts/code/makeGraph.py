#! /usr/bin/env python
#import PIL as pil
from numpy import *
from numpy.linalg import *
from scipy.sparse import *
from scipy.sparse.linalg import *

def makeGraph(im, r):
  '''makeGraph - generate the W and D matrices for normalized graph cuts.
  params:
    im - numpy matrix of image.
    r - radius
  '''
  sigma = r/3.0
  F = im.flatten()
  x = arange(0,im.shape[0])
  y = arange(0,im.shape[1])
  loc = zeros([im.shape[0],im.shape[1],2])
  loc[:,:,1] = x
  loc[:,:,2] = y
  xy = loc.reshape(len(F),1)
  W = lil_matrix((len(F),len(F)))

  for i in range(1,len(F)):
    for j in range(i,len(F)):
      difference = xy[i,:] - xy[j,:]
      distance = linalg.norm(difference)
      if distance <= r:
        Fdiff = F[i]-F[j]
        Fdiff = Fdiff*Fdiff # todo - change if F is more thana value..
        W[i,j] = exp(-(distance+Fdiff)/sigma)
    if i%100 == 0: # poor man's progress bar
      print (100 * (i*1.0/len(F)))
  return W
  
