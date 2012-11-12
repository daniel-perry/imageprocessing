function out = resample_nearest( Image, index )

if index(1) < 1 || index(1) > size(Image,1) || index(2) < 1 || index(2) > size(Image,2)
  out = 0;
  return 
end

loc = round(index(1:2));
out = Image(loc(1),loc(2));
