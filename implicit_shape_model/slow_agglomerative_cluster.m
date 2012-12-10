% agglomerative_cluster -  a hierarchical clustering method
%   each patch is intialized to be it's own cluster.  clusters
%   are joined until they pass the similarity threshold.
% params:
% patches - the patch data
% threshold - clustering threshold
% returns:
% clusters - cell array of patch indices, representing the clusters
function clusters = agglomerative_cluster( patches, threshold, max_iters )

clusters = {};

% initialize each patch as its own cluster
patches_count = size(patches,1)
for i=1:patches_count
  if mod(i,10000) == 0
    i = i
  end
  clusters{end+1} = [i];
end

clusters_count = 0;
iters = 0;
progress = 'starting the clustering iterations'
for iters = 1:max_iters
  count = size(clusters,2);
  if mod(iters,100) == 0
    iters = iters
    count = count
  end
  if count == 1 || count == clusters_count % loop until we converge..
    break
  end
  clusters_count = count;
  leave_loops = false;
  for i=1:count
    for j=i+1:count
      cluster_size = size(clusters);
      if isempty(clusters{i}) || isempty(clusters{j})
        continue
      end
      sim = similarity( clusters{i}, clusters{j}, patches );
      if sim > threshold
        % merge clusters
        %merged = merge( clusters{i}, clusters{j} )
        clusters{i} = merge( clusters{i}, clusters{j} );
        clusters(j) = []; % remove merged cluster
        % dims changed, start loops over
        leave_loops = true;
        break
      end
    end
    if leave_loops
      break
    end
  end
end
result = sprintf('converged after %d iterations to %d clusters', iters, clusters_count)

% merge two vectors (ie 1-d matrices)
function result = merge( a, b )
  result = [a b];

