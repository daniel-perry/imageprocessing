% extract_patches_neighbors - extract patches at each point of interest and neighbors
%  interest points are identified by the harris key point detector.
% returns a matrix of patches
% params:
% images - cell array of images
% radius - patch radius
% neighbor_radius - how large of a radius of neighbors to include in extraction
% return:
% matrix where each row is a patch 
% and a matrix of corresponding patch locations
function [patches, locations] = extract_patches_neighbors( images, radius , neighbor_radius )

addpath('external/keypointExtraction')

side = 1+2*radius;
patchlength = side*side;

n = max(size(images));

patches = [];
locations = [];

for i=1:n
  image = images{i};
  keypoints = kp_harris( image );

  for kpi=1:size(keypoints,1)
    pt_location = keypoints(kpi,:);
    %for r=pt_location(1)-(neighbor_radius*radius):radius/2:pt_location(1)+(neighbor_radius*radius)
    for r=pt_location(1):pt_location(1)
      %for c=pt_location(2)-(neighbor_radius*radius):radius/2:pt_location(2)+(neighbor_radius*radius)
      for c=pt_location(2):pt_location(2)
        if r > 0 && r <= size(image,1) && c >0 && c <= size(image,2)
          location = [r c];
          patch = extract_patch( image, radius, location );
          patches = [patches; patch(:)'];
          locations = [locations; location];
        end
      end
    end
  end

end

