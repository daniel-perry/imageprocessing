% similarity - similarity score between two patches
% params:
% cluster1,2 - two clusters to be compared
% return:
% score - similarity score
function score = similarity( cluster1, cluster2 , patches )

sum_cor = 0;

n1 = size(cluster1,2);
n2 = size(cluster2,2);

for i=1:n1
  for j=1:n2
    cor = ngc( patches(cluster1(i),:) , patches(cluster2(j),:) );
    sum_cor = sum_cor + cor;
  end
end

score = sum_cor / (n1*n2);

