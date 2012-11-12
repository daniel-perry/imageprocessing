% params:
% image1_fn: filename of first image
% image2_fn: filename of second image
% num_points: number of correspondence points
% points_out_fn: prefix filename of where to save the list of correspondence points.
function get_points(image1_fn, image2_fn, num_points, points_out_prefix)

im1 = imread(image1_fn);
im2 = imread(image2_fn);

sprintf('The images will now be shown, click each in turn to create the correspondence points..')

subplot(2,1,1)
imshow(im1)
subplot(2,1,2)
imshow(im2)

im1_points_x = zeros(1,num_points);
im1_points_y = zeros(1,num_points);
im2_points_x = zeros(1,num_points);
im2_points_y = zeros(1,num_points);
for i=1:num_points
  sprintf('top image')
  [x,y] = ginput(1)
  im1_points_x(i) = x;
  im1_points_y(i) = y;
  sprintf('bottom image')
  [x,y] = ginput(1)
  im2_points_x(i) = x;
  im2_points_y(i) = y;
end

dlmwrite(sprintf('%s%s',points_out_prefix,'_im1_x.out'),im1_points_x);
dlmwrite(sprintf('%s%s',points_out_prefix,'_im1_y.out'),im1_points_y);
dlmwrite(sprintf('%s%s',points_out_prefix,'_im2_x.out'),im2_points_x);
dlmwrite(sprintf('%s%s',points_out_prefix,'_im2_y.out'),im2_points_y);

