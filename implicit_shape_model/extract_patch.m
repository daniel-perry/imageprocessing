% extract_patch - extract a single patch at the specified point.
% params:
% image - image data
% radius - patch radius
% location - patch location
% return:
% patch at that location
function patch = extract_patch( image, radius, location )

side = 1+2*radius;
patch = zeros( side, side );

for r=1:side
  im_r = location(1)+(r-radius-1);
  if im_r > 0 && im_r <= size(image,1) 
    for c=1:side
      im_c = location(2)+(c-radius-1);
      if im_c > 0 && im_c <= size(image,2)
        patch(r,c) = image(im_r,im_c);
      end
    end
  end
end

