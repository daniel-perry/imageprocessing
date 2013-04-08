#
# Copyright (c) 2013 Daniel perry
#

include("../../common/image.jl") # for reading, displaying images

using NonlocalDenoising

function main()
  if length(ARGS) == 0
    println("usage: scriptname <noisy-image> <output-image> <patch-radius> <search-radius> <patch-sigma> <kernel-sigma>")
    return
  end
  noisy_fn = ARGS[1]
  out_fn = ARGS[2]
  radius = parse_int(ARGS[3])
  searchRadius = parse_int(ARGS[4])
  patchSigma  = parse_float(ARGS[5]) # h
  kernelSigma = parse_float(ARGS[6])

  noisy = imread(noisy_fn)
  noisy = rgb2gray(noisy)

  #sigma = 0.1 # should approximate the noise model
  #kernelSigma = 0.8

  denoised = nlMeans( noisy, radius, searchRadius, patchSigma, kernelSigma )

  println("max:",max(denoised))
  println("min:",min(denoised))

  imwrite(denoised, out_fn)
  #imshow(denoised)
end

main() # entry point
