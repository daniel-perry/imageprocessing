function out = resample_linear( Image, index )

if index(1) < 1 || index(1) > size(Image,1) || index(2) < 1 || index(2) > size(Image,2)
  out = 0;
  return
end

ul = floor(index);
lr = ceil(index);
ur = [lr(1); ul(2); 1];
ll = [ul(1); lr(2); 1];

x = index(1)-ul(1);
y = index(2)-ul(2);

out = Image(ul(1),ul(2))*(1-x)*(1-y)...
     +Image(ur(1),ur(2))*x*(1-y)...
     +Image(ll(1),ll(2))*(1-x)*y...
     +Image(lr(1),lr(2))*x*y;

