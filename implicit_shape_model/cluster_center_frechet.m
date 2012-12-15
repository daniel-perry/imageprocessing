% cluster_center - find the cluster center.. using 
%                  frechet mean of the existing patches.. ie the patch most similar to all of them.
% params:
% cluster - the cluster
% patches - patch data
function center = cluster_center_frechet( cluster, patches )

center = zeros(size(patches(1,:)));
max_sim = 0;
for j=1:size(cluster,2)
  sim = similarity( [cluster(j)], cluster, patches ); 
  if sim > max_sim
    center = patches(cluster(j),:);
    max_sim = sim;
  end
end

