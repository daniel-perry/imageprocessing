% extract_patches - extract patches at each point of interest
%  interest points are identified by the harris key point detector.
% returns a matrix of patches
% params:
% images - cell array of images
% radius - patch radius
% return:
% matrix where each row is a patch 
% and a matrix of corresponding patch locations
function [patches, locations] = extract_patches( images, radius )

addpath('external/keypointExtraction')

side = 1+2*radius;
patchlength = side*side;

n = max(size(images));

patches = zeros(1,patchlength);
locations = [];

for i=1:n
  image = images{i};
  keypoints = kp_harris( image );

  start_i = 0;
  if i == 1
    patches = zeros(size(keypoints,1),patchlength);
  else
    tmp = patches;
    patches = zeros(size(tmp,1)+size(keypoints,1),patchlength);
    patches(1:size(tmp,1),:) = tmp;
    start_i=size(tmp,1);
  end

  for kpi=1:size(keypoints,1)
    patch = extract_patch( image, radius, keypoints(kpi,:) );
    patches(start_i+kpi,:) = patch(:);
  end

  locations = [locations; keypoints];

end

