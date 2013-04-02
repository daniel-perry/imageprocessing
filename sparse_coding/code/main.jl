#
# Copyright (c) 2013 Daniel perry
#

include("image.jl") # for reading, displaying images

using SparseDictionary

function main()
  circle = imread("../images/circle.png")
  circle = rgb2gray(circle)

  c = circle[:]
  d = [c*20 c/20 c*50 c/50 c*100 c/100]
  a = matchingPursuit(c,d,2)
  println(a)
end

main() # entry point
