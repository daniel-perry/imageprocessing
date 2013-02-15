% cluster_centers - find the cluster centers.. for now we
%                  just use the mean patches.
% params:
% clusters - cluster lists
% patches - patch data
function centers = cluster_centers( clusters, patches )

num_clusters = size(clusters,2);

centers = zeros(num_clusters,size(patches,2));

for i=1:num_clusters
  cluster = clusters{i};
  centers(i,:) = cluster_center( cluster, patches );
end
