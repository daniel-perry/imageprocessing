% main - runs the complete program

% run preprocessing, and save results:
%{
[train_cars_pos, train_cars_neg , test_cars ] = preprocess_cars( 'images/CarData' );
save 'car_data.mat' train_cars_pos train_cars_neg test_cars
%}

% load preprocessed results (to skip preprocessing step...)
load 'car_data.mat' % train_cars_pos, train_cars_neg , test_cars 

% run patch extraction:
%{
radius = 12 % 25x25 patches
train_pos_patches = extract_patches( train_cars_pos, radius );
train_neg_patches = extract_patches( train_cars_neg, radius );
test_patches = extract_patches( test_cars, radius );
save 'patch_data.mat' train_pos_patches train_neg_patches test_patches
%}

% load extracted patches (to skip patch extraction...)
load 'patch_data.mat' % train_pos_patches train_neg_patches test_patches

cluster_thold = 10
patch_count = 10000
tic
train_pos_clusters = agglomerative_cluster( train_pos_patches(1:patch_count,:), cluster_thold );
train_pos_time = toc
tic
train_neg_clusters = agglomerative_cluster( train_neg_patches(1:patch_count,:), cluster_thold );
train_neg_time = toc
cluster_fn = sprintf('clusters_%d_%d.mat',cluster_thold,patch_count)
save(cluster_fn, 'train_pos_clusters', 'train_neg_clusters')


