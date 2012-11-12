function out = resample_linear( Image, index )

if index(1) < 1 || index(1) > size(Image,1) || index(2) < 1 || index(2) > size(Image,2)
  return 0
end

ul = floor(index);
lr = ceil(index);
ur = [lr(1); ul(2); 1];
ll = [ul(1); lr(2); 1];

out = Image(ul)*(ur(1)-index(1))*(lr(2)-index(2))...
     +Image(ur)*(index(1)-ul(1))*(lr(2)-index(2))...
     +Image(ll)*(ur(1)-index(1))*(index(2)-ul(2))...
     +Image(lr)*(index(1)-ul(1))*(index(2)-ul(2));

