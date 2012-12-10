% agglomerative_cluster -  a hierarchical clustering method
%   each patch is intialized to be it's own cluster.  clusters
%   are joined until they pass the similarity threshold.
% params:
% patches - the patch data
% threshold - clustering threshold
% returns:
% clusters - cell array of patch indices, representing the clusters
function clusters = agglomerative_cluster( patches, threshold )

clusters = {};

% initialize each patch as its own cluster
patches_count = size(patches,1)
for i=1:patches_count
  if mod(i,10000) == 0
    i = i
  end
  clusters{end+1} = [i];
end

progress = 'starting the clustering iterations'
count = size(clusters,2);
for i=1:count
  if mod(i,1000) == 0
    i = i 
  end
  if isempty(clusters{i})
    continue
  end
  for j=i+1:count
    if mod(j,1000) == 0
      j = j
    end
    if isempty(clusters{j})
      continue
    end
    sim = similarity( clusters{i}, clusters{j}, patches );
    if sim > threshold
      % merge clusters
      clusters{i} = merge( clusters{i}, clusters{j} );
      %clusters(j) = []; % remove merged cluster
      clusters{j} = []; % mark as removed (but keep cluster list order..)
    end
  end
end
old_clusters = clusters;
clusters = {};
for i=1:count
  if ~ isempty(old_clusters{i})
    clusters{end+1} = old_clusters{i};
  end
end
count = size(clusters,2);
result = sprintf('converged to %d clusters', count)

% merge two vectors (ie 1-d matrices)
function result = merge( a, b )
  result = [a b];

