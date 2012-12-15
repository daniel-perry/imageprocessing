% cluster_center - find the cluster center.. for now we
%                  just use the mean patch.
% params:
% cluster - the cluster
% patches - patch data
function center = cluster_center( cluster, patches )

center = zeros(size(patches(1,:)));
for j=1:size(cluster,2)
  center = center + patches(cluster(j),:);
end
center = center / size(cluster,2);

