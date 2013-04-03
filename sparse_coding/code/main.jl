#
# Copyright (c) 2013 Daniel perry
#

include("image.jl") # for reading, displaying images

using SparseDictionary

# chunk up an image, into non-overlapping chunks
function enChunk(image,chunkSize)
  chunkLength = chunkSize[1] * chunkSize[2]
  imageSize=size(image)
  chunks = Array(Float32, (chunkLength,0) )
  for r=1:chunkSize[1]:imageSize[1]
    for c=1:chunkSize[2]:imageSize[2]
      piece = zeros(chunkSize)
      #println("image size: ",imageSize)
      #println("image:")
      #println(r:min(r+chunkSize[1]-1,imageSize[1]))
      #println(c:min(c+chunkSize[2]-1,imageSize[2]))
      #println("patch:")
      #println(1:min(chunkSize[1],imageSize[1]-r+1))
      #println(1:min(chunkSize[2],imageSize[2]-c+1))
      piece[1:min(chunkSize[1],imageSize[1]-r+1), 1:min(chunkSize[2],imageSize[2]-c+1)] = image[r:min(r+chunkSize[1]-1,imageSize[1]),c:min(c+chunkSize[2]-1,imageSize[2])]
      chunks = [chunks piece[:]]
    end
  end
  chunks
end

# combine non-overlapping chunks into a full image
function deChunk(X,D,chunkSize,imageSize)
  image = zeros(imageSize)
  for r=1:chunkSize[1]:imageSize[1]
    for c=1:chunkSize[2]:imageSize[2]
      ind = r*chunkSize[2]+c
      if ind <= size(X,2)
        piece = D*X[:,ind]
        piece = reshape(piece,chunkSize)
        image[r:min(r+chunkSize[1]-1,imageSize[1]),c:min(c+chunkSize[2]-1,imageSize[2])] = piece[1:min(chunkSize[1],imageSize[1]-r+1), 1:min(chunkSize[2],imageSize[2]-c+1)]
      end
    end
  end
  image
end

# create a random dictionary of dimension (atomSize,atomCount)
# generated following procedure defined in section V of the original k-SVD paper.
function randomDictionary(atomSize, atomCount)
  genSize = 50
  comps = 3
  gen = rand(atomSize,genSize)
  for i=1:genSize
    gen[:,i] = gen[:,i] * (1/norm(gen[:,i],2))
  end
  d = zeros(atomSize,atomCount)
  for i=1:atomCount
    coeff = rand(comps)'
    coeff = coeff / sum(coeff)  # random coefficients should sum to 1..
    loc = rand(Uint32, comps)
    loc = mod(loc,genSize) + ones(Uint32,comps) # random locations in the generating dictionary
    parts = gen[:,loc]
    coeff = ones(comps,1)*coeff
    atom = sum( parts*coeff, 2 )
    d[:,i] = atom
  end
  d
end

function main()
  sailboat = imread("../images/sailboat.png")
  sailboat = rgb2gray(sailboat)

  chunkSize = (8,8)
  chunkLength = chunkSize[1] * chunkSize[2]

  f = enChunk( sailboat , chunkSize )
  d = randomDictionary( chunkLength , 1500 )
  #a = matchingPursuit(c,d,2)
  #x,d = kSVD(f[:,1:100],d, 20,2)
  x,d = kSVD(f,d, 20,10)
  
  newsb = deChunk( x,d , chunkSize, size(sailboat) )
  imwrite( newsb, "tmp.png" )
end

main() # entry point
