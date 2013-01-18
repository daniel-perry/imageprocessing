% main - runs the complete program

% run preprocessing, and save results:
%{
[train_cars_pos, train_cars_neg , test_cars ] = preprocess_cars( 'images/CarData' );
save 'car_data.mat' train_cars_pos train_cars_neg test_cars
%}

% load preprocessed results (to skip preprocessing step...)
load 'car_data.mat' % train_cars_pos, train_cars_neg , test_cars 

% run patch extraction:
radius = 12 % 25x25 patches
%{
train_pos_patches = extract_patches( train_cars_pos, radius );
train_neg_patches = extract_patches( train_cars_neg, radius );
test_patches = extract_patches( test_cars, radius );
save 'patch_data.mat' train_pos_patches train_neg_patches test_patches
%}

% load extracted patches (to skip patch extraction...)
load 'patch_data.mat' % train_pos_patches train_neg_patches test_patches

cluster_thold = 15
%patch_count =  -1 % all patches - takes about 21 hrs each patch set 
patch_count = 1000  % clustering takes about 5 min each patch set, codebook generation takes 10 min for both.
%patch_count = 10000 % takes about 45 min each patch set
cluster_fn = 'clusters.mat'; % default
if patch_count > 0
  cluster_fn = sprintf('clusters_%d_%d.mat',cluster_thold,patch_count)
  codebook_fn = sprintf('codebook_fr_%d_%d.mat',cluster_thold,patch_count)
else
  cluster_fn = sprintf('clusters_%d_all.mat',cluster_thold)
  codebook_fn = sprintf('codebook_fr_%d_all.mat',cluster_thold)
end

%{
tic
if patch_count > 0
  train_pos_clusters = agglomerative_cluster( train_pos_patches(1:patch_count,:), cluster_thold );
else 
  train_pos_clusters = agglomerative_cluster( train_pos_patches, cluster_thold );
end
train_pos_time = toc
tic
if patch_count > 0
  train_neg_clusters = agglomerative_cluster( train_neg_patches(1:patch_count,:), cluster_thold );
else
  train_neg_clusters = agglomerative_cluster( train_neg_patches, cluster_thold );
end
train_neg_time = toc
save(cluster_fn, 'train_pos_clusters', 'train_neg_clusters')
%}

load(cluster_fn)  % train_pos_clusters, train_neg_clusters

if patch_count > 0
  tic
  codebook_pos = create_codebook( train_pos_clusters, train_pos_patches(1:patch_count,:), cluster_thold, train_cars_pos, radius );
  codebook_neg = create_codebook( train_neg_clusters, train_neg_patches(1:patch_count,:), cluster_thold, train_cars_neg, radius );
  both_codebooks = toc
else
  tic
  codebook_pos = create_codebook( train_pos_clusters, train_pos_patches, cluster_thold, train_cars_pos, radius);
  codebook_neg = create_codebook( train_neg_clusters, train_neg_patches, cluster_thold, train_cars_neg, radius);
  both_codebooks = toc
end
save(codebook_fn, 'codebook_pos', 'codebook_neg');

%load(codebook_fn) % 'codebook_pos', 'codebook_neg' 

%show_test( test_cars{1}, codebook_pos, codebook_neg, cluster_thold, radius )

