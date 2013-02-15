% hough_coverage - find the coverage for all entries in the codebook
% params:
%  test_image - the image to search
%  codebook_pos - the codebook for positive patches
%  codebook_neg - the codebook for negative patches
%  threshold - cluster threshold
%  patch_radius - radius of patches
% returns:
%  accum - the hough accumulator
function accum = hough_coverage( test_image, codebook_pos, codebook_neg, threshold, patch_radius )

images = {};
images{1} = test_image;
[patches,locations] = extract_patches_neighbors( images, patch_radius, 1 );
num_patches = size(patches,1)

accum = zeros(size(test_image));

n_patches = size(patches,1);
for i=1:n_patches
  apatch = patches(i,:);
  alocation = locations(i,:);
  accum = codebook_matches( accum, apatch, alocation, codebook_pos, codebook_neg, threshold, 1 );
end

