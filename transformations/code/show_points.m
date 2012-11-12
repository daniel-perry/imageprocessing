function show_points(image1_fn,image2_fn,points_prefix)

im1 = imread(image1_fn);
im2 = imread(image2_fn);

im1_x = dlmread(sprintf('%s%s',points_prefix,'_im1_x.out'));
im1_y = dlmread(sprintf('%s%s',points_prefix,'_im1_y.out'));
im2_x = dlmread(sprintf('%s%s',points_prefix,'_im2_x.out'));
im2_y = dlmread(sprintf('%s%s',points_prefix,'_im2_y.out'));

num_points = max(size(im1_x))

subplot(2,1,1)
imshow(im1)
hold on
for i=1:num_points
  text(im1_x(i)+8,im1_y(i),sprintf('%d',i),'Color',[0,0,1])
end
plot(im1_x,im1_y,'ro')
hold off


subplot(2,1,2)
imshow(im2)
hold on
for i=1:num_points
  text(im2_x(i)+8,im2_y(i),sprintf('%d',i),'Color',[0,0,1])
end
plot(im2_x,im2_y,'ro')
hold off

