% preprocess_cars - preprocess the UIUC Cars data set
% steps:
% 1. read
% 2. supersample to a larger size
function [train_cars_pos,train_cars_neg,test_cars] = preprocess_cars( dir , out_fn )

resample_ratio = 1.0 / 2.0;

% external functions
addpath('external/imresample');

train_dir = sprintf('%s/TrainImages', dir)
test_dir = sprintf('%s/TestImages', dir)

train_cars_pos = {};
train_cars_neg = {};
test_cars = {};

for i=0:549
  fname = sprintf('%s/pos-%d.pgm',train_dir,i);
  im = imread(fname);
  im = uint8(imresample( [1 1], im, [resample_ratio resample_ratio], 'cubic' ));
  train_cars_pos = {train_cars_pos{:} im};
end
size_train_pos = size(train_cars_pos)

for i=0:499
  fname = sprintf('%s/neg-%d.pgm',train_dir,i);
  im = imread(fname);
  im = uint8(imresample( [1 1], im, [resample_ratio resample_ratio], 'cubic' ));
  train_cars_neg = {train_cars_neg{:} im};
end
size_train_neg = size(train_cars_neg)

for i=0:169
  fname = sprintf('%s/test-%d.pgm',test_dir,i);
  im = imread(fname);
  im = uint8(imresample( [1 1], im, [resample_ratio resample_ratio], 'cubic' ));
  test_cars = {test_cars{:} im};
end
size_test = size(test_cars)

