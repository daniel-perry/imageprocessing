#
# Copyright (c) 2013 Daniel perry
#

include("../../common/image.jl") # for reading, displaying images

using SparseDictionary
using MAT

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
function deChunk(F,chunkSize,imageSize)
  image = zeros(imageSize)
  ind = 1
  for r=1:chunkSize[1]:imageSize[1]
    for c=1:chunkSize[2]:imageSize[2]
      piece = F[:,ind]
      piece = reshape(piece,chunkSize)
      image[r:min(r+chunkSize[1]-1,imageSize[1]),c:min(c+chunkSize[2]-1,imageSize[2])] = piece[1:min(chunkSize[1],imageSize[1]-r+1), 1:min(chunkSize[2],imageSize[2]-c+1)]
      ind = ind + 1
    end
  end
  image
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
  println("testChunk()")
  sailboat = imread("../images/sailboat.png")
  sailboat = rgb2gray(sailboat)
  imshow(sailboat)
  println("type: ",typeof(sailboat))
  println("min: ",min(sailboat))
  println("max: ",max(sailboat))
  chunkSize = (8,8)
  chunkLength = chunkSize[1] * chunkSize[2]
  f = enChunk( sailboat , chunkSize )
  r = deChunk( f, chunkSize, size(sailboat) )
  println("type: ",typeof(r))
  println("min: ",min(r))
  println("max: ",max(r))
  imshow(r)
end

function testMatchingPursuitChunked()
  sailboat = imread("../images/sailboat_sm.png")
  sailboat = rgb2gray(sailboat)
  sailboat_noisy = imread("../images/sailboat_10_sm.png")
  sailboat_noisy = rgb2gray(sailboat_noisy)
  println("image size: ", size(sailboat))

  chunkSize = (2,2)
  chunkLength = chunkSize[1] * chunkSize[2]

  f = enChunk( sailboat , chunkSize )
  #d = enChunk( sailboat_noisy , chunkSize )
  #d = randomDictionary( chunkLength , 1500 , f ) # generate random dict from image patches
  d = randomDictionary( chunkLength , 1500 ) # generate random dict from image patches
  for i=1:size(d,2)
    d[:,i] = d[:,i]/norm(d[:,i],2)
  end
  a = zeros(size(d,2),size(f,2))
  cnt = 0
  for i=1:size(f,2)
    a[:,i] = matchingPursuit(f[:,i],d,2)
    cnt = cnt + nnz(a[:,i])
  end
  println("avg nnz: ", cnt/size(f,2))
  println("output size:",size(a))
  r = deChunk( d*a , chunkSize, size(sailboat) )
  println("result:")
  println("size:",size(r))
  println("min:",min(r))
  println("max:",max(r))

  imshow(r)
end

function testKSVD()
  sailboat = imread("../images/sailboat_sm.png")
  sailboat = rgb2gray(sailboat)

  println("image type:", typeof(sailboat) )

  chunkSize = (2,2)
  chunkLength = chunkSize[1] * chunkSize[2]

  f = enChunk( sailboat , chunkSize )
  d = randomDictionary( chunkLength , 1500 )
  #d = randomDictionary( chunkLength , 1500 , f ) # generate random dict from image patches
  #x,d = kSVD(f[:,1:100],d, 20,2)
  x,d = kSVD(f,d, 50,100)

  println("max: ",max(x))
  println("min: ",min(x))
  println("mean: ",mean(x))
  
  newsb = deChunk( d*x , chunkSize, size(sailboat) )

  println("out type: ", typeof(newsb))

  println("max: ",max(newsb))
  println("min: ",min(newsb))
  println("mean: ",mean(newsb))

  imwrite( newsb, "ksvd.png" )
  imshow(newsb)
end

# create a random dictionary of dimension (atomSize,atomCount)
# generated following procedure defined in section V of the original k-SVD paper.
# using a given generating matrix
function randomDictionary(atomSize, atomCount, gen)
  genSize = size(gen,2)
  comps = 3
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

# create a random dictionary of dimension (atomSize,atomCount)
# generated following procedure defined in section V of the original k-SVD paper.
function randomDictionary(atomSize, atomCount)
  genSize = 50
  gen = rand(atomSize,genSize)
  randomDictionary(atomSize, atomCount, gen)
end

# Create an initial dictionary from the DCT frame
# adapted from matlab implementation availabe here:
# http://www.cs.technion.ac.il/~elad/software/
function dctDictionary(atomSize, atomCount)
  Pn = convert(Uint64,ceil(sqrt(atomCount)))
  bb = convert(Uint64,ceil(sqrt(atomSize)))
  DCT=zeros(bb,Pn)
  for k=0:1:Pn-1
      V=cos([i::Float64 for i=0.0:bb-1]'*k*pi/Pn)
      if k>0
        V=V-mean(V)
      end
      DCT[:,k+1]=V/norm(V)
  end
  DCT=kron(DCT,DCT)
end

function main(args)
  #testMatchingPursuit()
  #testKSVD()
  #testMatchingPursuitChunked()
  #return

  if length(args) == 0
    println("usage: scriptname <noisy-image> <output-image> <patch-radius> <max-nnz>")
    return
  end
  noisy_fn = args[1]
  out_fn = args[2]
  radius = parse_int(args[3])
  max_nnz = parse_int(args[4])

  noisy = imread(noisy_fn)
  noisy = rgb2gray(noisy)

  println("INFO: building initial dictionary")
  #D = randomDictionary( (1+2*radius)^2 , 256 )
  D = dctDictionary( (1+2*radius)^2 , 256 )
  println("INFO: done building initial dictionary")

  parts = split(noisy_fn,"/")
  noisy_fn = parts[length(parts)]
  noisy_fn = replace(noisy_fn, ".", "_")
  noisy_fn = string(noisy_fn , "_" , radius)

  maxIters = 10
  noise_sigma = 10
  #relaxation = 0.00034 * noise_sigma
  #relaxation = 0.005 * noise_sigma # sailboat
  relaxation = 0.01 * noise_sigma # camera

  println("INFO: dictionary size:",size(D))
  println("INFO: sparsity:",max_nnz)
  println("INFO: relaxation:",relaxation)

  useKSVD = true
  denoised,D = kSVDDenoising( noisy_fn, noisy, D, max_nnz, maxIters, radius, relaxation, useKSVD )

  mfile = matopen(string(out_fn,".mat"),"w")
  write(mfile, "denoised",denoised)
  write(mfile, "dictionary",D)
  close(mfile)

  imwrite(denoised, out_fn)
  #imshow(denoised)
end

main(ARGS) # entry point
