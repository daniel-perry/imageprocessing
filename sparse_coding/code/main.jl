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
      ind = (r-1)*chunkSize[2]+c
      if ind <= size(X,2)
        piece = D*X[:,ind]
        piece = reshape(piece,chunkSize)
        image[r:min(r+chunkSize[1]-1,imageSize[1]),c:min(c+chunkSize[2]-1,imageSize[2])] = piece[1:min(chunkSize[1],imageSize[1]-r+1), 1:min(chunkSize[2],imageSize[2]-c+1)]
      end
    end
  end
  image
end

# combine non-overlapping chunks into a full image
function deChunk(F,chunkSize,imageSize)
  image = zeros(imageSize)
  for r=1:chunkSize[1]:imageSize[1]
    for c=1:chunkSize[2]:imageSize[2]
      ind = (r-1)*chunkSize[2]+c
      if ind <= size(F,2)
        piece = F[:,ind]
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

function testKSVD()
  sailboat = imread("../images/sailboat_sm.png")
  sailboat = rgb2gray(sailboat)

  println("image type:", typeof(sailboat) )

  chunkSize = (8,8)
  chunkLength = chunkSize[1] * chunkSize[2]

  f = enChunk( sailboat , chunkSize )
  d = randomDictionary( chunkLength , 1500 )
  #a = matchingPursuit(c,d,2)
  #x,d = kSVD(f[:,1:100],d, 20,2)
  x,d = kSVD(f,d, 50,15)

  println("max: ",max(x))
  println("min: ",min(x))
  println("mean: ",mean(x))
  
  newsb = deChunk( x,d , chunkSize, size(sailboat) )

  println("out type: ", typeof(newsb))

  println("max: ",max(newsb))
  println("min: ",min(newsb))
  println("mean: ",mean(newsb))

  imwrite( newsb, "tmp.png" )
end


function testMatchingPursuit()
  sailboat = imread("../images/sailboat_sm.png")
  sailboat = rgb2gray(sailboat)
  sailboat_noisy = imread("../images/sailboat_10_sm.png")
  sailboat_noisy = rgb2gray(sailboat_noisy)

  f = sailboat
  dp = sailboat_noisy
  d = [dp[:] dp[:] dp[:]] # encoded the image using a noisy version of itself
  for i=1:size(d,2)
    d[:,i] = d[:,i]/norm(d[:,i],2)
  end
  a = matchingPursuit(f,d,2)
  r = d*a
  r = reshape(r,size(sailboat))
  println("result:")
  println("size:",size(r))
  println("min:",min(r))
  println("max:",max(r))

  imshow(r)
end

function testChunk()
  sailboat = imread("../images/sailboat.png")
  sailboat = rgb2gray(sailboat)
  chunkSize = (8,8)
  chunkLength = chunkSize[1] * chunkSize[2]
  f = enChunk( sailboat , chunkSize )
  r = deChunk( f, chunkSize, size(sailboat) )
  imshow(r)
end

function testMatchingPursuitChunked()
  sailboat = imread("../images/sailboat_sm.png")
  sailboat = rgb2gray(sailboat)
  sailboat_noisy = imread("../images/sailboat_10_sm.png")
  sailboat_noisy = rgb2gray(sailboat_noisy)
  println("image size: ", size(sailboat))

  chunkSize = (8,8)
  chunkLength = chunkSize[1] * chunkSize[2]

  f = enChunk( sailboat , chunkSize )
  d = enChunk( sailboat_noisy , chunkSize )
  for i=1:size(d,2)
    d[:,i] = d[:,i]/norm(d[:,i],2)
  end
  a = zeros(size(d,2),size(f,2))
  for i=1:size(f,2)
    a[:,i] = matchingPursuit(f[:,i],d,2)
  end
  println("output size:",size(a))
  r = deChunk( a,d , chunkSize, size(sailboat) )
  println("result:")
  println("size:",size(r))
  println("min:",min(r))
  println("max:",max(r))

  imshow(r)
end

function main()
  #testMatchingPursuitChunked()
  testChunk()
end

main() # entry point
