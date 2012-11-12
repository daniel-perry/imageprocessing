function out = transform( Image, Matrix, Interpolation )

imsize = size(Image);

% We'd like to capture all pixels after the transformation, so
% First map corners of image to figure out extent of transformation:
%ul = [0;0;1]
%ur = [imsize(1)-1;0;1]
%ll = [0;imsize(2)-1;1]
%lr = [imsize(1)-1;imsize(2)-1;1]
%
%transform_ul = Matrix * ul
%transform_ur = Matrix * ur
%transform_ll = Matrix * ll
%transform_lr = Matrix * lr
%
%max_x = max([transform_ul(1) transform_ur(1) transform_ll(1) transform_lr(1)]);
%min_x = min([transform_ul(1) transform_ur(1) transform_ll(1) transform_lr(1)]);
%max_y = max([transform_ul(2) transform_ur(2) transform_ll(2) transform_lr(2)]);
%min_y = min([transform_ul(2) transform_ur(2) transform_ll(2) transform_lr(2)]);
%
%new_ul = [min_x;min_y;1]
%new_ur = [max_x;min_y;1]
%new_ll = [min_x;max_y;1]
%new_lr = [max_x;max_y;1]

% Now invert the matrix:
Inv = inv(Matrix);

% new image will be same size as original:
newsize = imsize;

out = zeros(newsize);

%dxdy = (new_lr(1:2) - new_ul(1:2)) ./ newsize';

for x = 0:newsize(1)-1
  for y = 0:newsize(2)-1
    %sample = ([x; y] .* dxdy);
    %sample = [sample(1:2); 1];
    sample = [x;y;1];
    trans_sample = [1;1;0] + (Inv * sample);
    if strcmp(Interpolation,'nearest')
      out(x+1,y+1) = resample_nearest(Image, trans_sample);
    elseif strcmp(Interpolation,'linear')
      out(x+1,y+1) = resample_linear(Image, trans_sample);
    else
      error('Unrecognized interpolation "%s"',Interpolation);
      return
    end
  end
end
out = uint8(out);
