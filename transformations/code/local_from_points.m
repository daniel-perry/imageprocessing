function [pts,alpha] = local_from_points(points_prefix, sigma)

im1_x = dlmread(sprintf('%s%s',points_prefix,'_im1_x.out'));
im1_y = dlmread(sprintf('%s%s',points_prefix,'_im1_y.out'));
im2_x = dlmread(sprintf('%s%s',points_prefix,'_im2_x.out'));
im2_y = dlmread(sprintf('%s%s',points_prefix,'_im2_y.out'));

X = [im1_x; im1_y];
Y = [im2_x; im2_y];

K = eye(size(X,2));

for i=1:size(X,2)
  for j=1:size(Y,2)
    if(i ~= j)
      a = X(:,i);
      b = X(:,j);
      K(i,j) = gauss_kernel( a , b , sigma);
    end
  end
end
K = K
V = (Y(1,:)-X(1,:))
alpha_x = K \ (Y(1,:)-X(1,:))';
alpha_y = K \ (Y(2,:)-X(2,:))';

alpha = [alpha_x'; alpha_y'];
pts = Y;

