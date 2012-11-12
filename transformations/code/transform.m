% params:
% Image - the original image
% Matrix - transformation matrix
% Interpolation - either 'linear' or 'nearest'
% samesize - whether output should be same size as input or not..
function out = transform( Image, Matrix, Interpolation, samesize )

imsize = size(Image);

% invert the matrix:
Inv = inv(Matrix);

if samesize
% new image will be same size as original:
newsize = imsize;

out = zeros(newsize);

for x = 0:newsize(1)-1
  for y = 0:newsize(2)-1
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

else % samesize = 0


% find extent of transformation:
ul = [0 0 1]';
ur = [imsize(1)-1 0 1]';
lr = [imsize(1)-1 imsize(2)-1 1]';
ll = [0 imsize(2)-1 1]';

t_ul = Matrix * ul;
t_ur = Matrix * ur;
t_lr = Matrix * lr;
t_ll = Matrix * ll;

max_x = max([ t_ul(1) t_ur(1) t_lr(1) t_ll(1) ]);
min_x = min([ t_ul(1) t_ur(1) t_lr(1) t_ll(1) ]);
max_y = max([ t_ul(2) t_ur(2) t_lr(2) t_ll(2) ]);
min_y = min([ t_ul(2) t_ur(2) t_lr(2) t_ll(2) ]);


newsize = [ceil(max_x-min_x) ceil(max_y-min_y)];
out = zeros(newsize);

for x = 0:newsize(1)-1
  for y = 0:newsize(2)-1
    sample = [min_x+x;min_y+y;1];
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


end % samesize

