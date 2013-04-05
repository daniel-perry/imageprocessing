# 
# Copyright (c) 2013 Daniel Perry
#

module NonlocalDenoising

export nlMeans

# create a gaussian kernal or specified size
function makeKernel(radius,sigma)
  side = 1+2*radius
  kernel = zeros(side,side)
  center = [radius+1,radius+1]
  for i=1:side
    for j=1:side
      diff = i-center[1]
      x = exp(-(diff*diff)/(2*sigma^2))
      kernel[i,j] = x*y
    end
  end
end

# NL Means implementation
#params:
# I - the noisy image
# patchRadius - the radius of the local patches
# searchRadius - the radius of the search box
function nlMeans(I,patchRadius,searchRadius, support)
  searchSide = 1+2*searchRadius
  DI = zeros(typeof(I[1,1]),size(I))
  for r=patchRadius+1:size(I,1)-patchRadius
    for c=patchRadius+1:size(I,2)-patchRadius
      if (r*size(I,2)+c)%100==0
        print(".") # poor man's progress bar
      end
      patch = I[r-patchRadius:r+patchRadius,c-patchRadius:c+patchRadius]
      center = patch[patchRadius+1,patchRadius+1]
      patch = patch[:]
      searchCorner = [max(patchRadius+1,min(size(I,1)-patchRadius,r-searchSide+1)), max(patchRadius+1,min(size(I,1)-patchRadius,c-searchSide+1))]
      if r > size(I,1)-searchSide
        searchCorner[1] = min(size(I,1)-patchRadius-searchSide,r-searchSide)
      end
      if c > size(I,2)-searchSide
        searchCorner[2] = min(size(I,2)-patchRadius-searchRadius,c-searchSide)
      end
      weights = 0.0
      pixels = 0.0
      for i=searchCorner[1]:searchCorner[1]+searchSide
        for j=searchCorner[2]:searchCorner[2]+searchSide
          searchPatch = I[i-patchRadius:i+patchRadius,j-patchRadius:j+patchRadius]
          searchCenter = searchPatch[patchRadius+1,patchRadius+1]
          searchPatch = searchPatch[:]
          #weight = dot(patch , searchPatch)
          diffnorm = norm(patch-searchPatch,2)
          weight = exp( - diffnorm^2 / support^2 )
          pixels = pixels + weight * searchCenter
          weights = weights + weight
        end
      end
      DI[r,c] = pixels/weights
    end
  end
  DI
end #function

end #module
