#
# Copyright (c) 2013 Daniel perry
#

include("../../common/image.jl") # for reading, displaying images

using NonlocalDenoising

function main()
  if length(ARGS) == 0
    println("usage: scriptname <noisy-image> <output-image> <patch-radius> <search-radius>")
    return
  end
  noisy_fn = ARGS[1]
  out_fn = ARGS[2]
  radius = parse_int(ARGS[3])
  searchRadius = parse_int(ARGS[4])

  noisy = imread(noisy_fn)
  noisy = rgb2gray(noisy)

  sigma = 0.1 # should approximate the noise model
  kernelSigma = 1

  denoised = nlMeans( noisy, radius, searchRadius, sigma, kernelSigma )

  imwrite(denoised, out_fn)
  #imshow(denoised)
end

main() # entry point
