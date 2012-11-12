function out = transform( Image, Matrix, Interpolation )

imsize = size(Image);

% invert the matrix:
Inv = inv(Matrix);

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
