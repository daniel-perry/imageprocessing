function A = affine_from_points(points_prefix)

im1_x = dlmread(sprintf('%s%s',points_prefix,'_im1_x.out'));
im1_y = dlmread(sprintf('%s%s',points_prefix,'_im1_y.out'));
im2_x = dlmread(sprintf('%s%s',points_prefix,'_im2_x.out'));
im2_y = dlmread(sprintf('%s%s',points_prefix,'_im2_y.out'));

% X * A = Y, solve for A

%X = [im1_x; im1_y; ones(size(im1_x))];
%Y = [im2_x; im2_y; ones(size(im2_x))];
X = [im1_x; im1_y];
Y = [im2_x; im2_y];
A = eye(3,3);

if size(X) == [2 3]
  %rot = Y * inv(X);
  %rot = [X;1 1 1]\[Y;1 1 1]
  A_tilde = [ Y(:,1)-Y(:,2) Y(:,1)-Y(:,3) ];
  P = [ X(:,1)-X(:,2) X(:,1)-X(:,3) ];
  %rot = A_tilde * inv(P);
  rot = P \ A_tilde;
  tran = Y(:,1) - rot * X(:,1);
  A(1:2,1:2) = rot;
  A(1:2,3) = tran';
else % overconstrained
  X_mean = mean(X,2);
  Y_mean = mean(Y,2);
  X_cent = zeros(size(X));
  Y_cent = zeros(size(Y));
  yx = zeros(2,2);
  xx = zeros(2,2);
  for i=1:size(X,2)
    X_cent(:,i) = X(:,i)-X_mean;
    Y_cent(:,i) = Y(:,i)-Y_mean;
    % outer product
    for j=1:2
      for k=1:2
        yx(j,k) = yx(j,k) + Y_cent(j,i)*X_cent(k,i);
        xx(j,k) = xx(j,k) + X_cent(j,i)*X_cent(k,i);
      end
    end
  end
  %rot = yx * inv(xx);
  rot = xx\yx;
  tran = Y_mean - rot * X_mean;
  A(1:2,1:2) = rot;
  A(1:2,3) = tran;
end


