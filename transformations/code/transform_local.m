% params:
% Image - the original image
% Matrix - transformation matrix
% Interpolation - either 'linear' or 'nearest'
function out = transform_local( Image, pts, alpha, sigma, Interpolation )

imsize = size(Image);

% new image will be same size as original:
newsize = imsize;

out = zeros(newsize);

for x = 0:newsize(1)-1
  for y = 0:newsize(2)-1
    sample = [x;y];
    trans_sample = sample;
    for i=1:size(alpha,2)
      v = pts(:,i);
      k = gauss_kernel( sample, v, sigma );
      trans_sample = trans_sample - k*alpha(:,i);
    end
    trans_sample = [([1;1] + trans_sample);1];
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

