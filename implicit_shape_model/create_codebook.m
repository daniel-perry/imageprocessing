% create_codebook - generate the codebook for clusters
% params:
% clusters - the computed clusters
% patches - the patch data
% threshold - the threshold used to generate the clusters
function codebook = create_codebook( clusters, patches, threshold, images, radius )

addpath('external/keypointExtraction')

n = max(size(images));
codebook = {};

old_clusters = clusters;
clusters = {};
c = 1;
for i=1:size(old_clusters,2)
  cluster = old_clusters{i};
  if size(cluster,2) > 3 % bias towards larger clusters
    clusters{c} = cluster;
    %center = cluster_center( cluster, patches );
    center = cluster_center_frechet( cluster, patches );
    codebook{c,1} = center;
    codebook{c,2} = []; % will be list of locations
    c = c + 1;
  end
end
num_codebooks = size(codebook,1)

for i=1:n
  image = images{i};
  keypoints = kp_harris( image );
  for kpi=1:size(keypoints,1)
    patch_pos = keypoints(kpi,:);
    patch = extract_patch( image, radius, patch_pos );
    patch = patch(:);
    patch = patch';
    for j=1:num_codebooks
      clustercenter = codebook{j,1};
      if ngc( clustercenter, patch ) > threshold
        object_center = size(image) ./ 2;
        loc = object_center - patch_pos;  % so that loc + found_pos = proposed center...
        codebook{j,2} = [loc; codebook{j,2}];
      end
    end 
  end
end
