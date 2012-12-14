% hough_coverage - find the coverage for all entries in the codebook
% params:
%  test_image - the image to search
%  codebook - the codebook
%  threshold - cluster threshold
%  patch_radius - radius of patches
% returns:
%  accum - the hough accumulator
function accum = hough_coverage( test_image, codebook, threshold, patch_radius )

images = {};
images{1} = test_image;
[patches,locations] = extract_patches( images, patch_radius );

accum = zeros(size(test_image));

n_patches = size(patches,1);
for i=1:n_patches
  apatch = patches(i,:);
  alocation = locations(i,:);
  accum = codebook_matches( accum, apatch, alocation, codebook, threshold );
end

