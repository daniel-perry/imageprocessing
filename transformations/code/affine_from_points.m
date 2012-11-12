function m = affine_from_points(points_prefix)

im1_x = dlmread(sprintf('%s%s',points_prefix,'_im1_x.out'));
im1_y = dlmread(sprintf('%s%s',points_prefix,'_im1_y.out'));
im2_x = dlmread(sprintf('%s%s',points_prefix,'_im2_x.out'));
im2_y = dlmread(sprintf('%s%s',points_prefix,'_im2_y.out'));

% A * X = Y, solve for A

X = [im1_x; im1_y; ones(size(im1_x))]
Y = [im2_x; im2_y; ones(size(im2_x))]

m = Y\X


