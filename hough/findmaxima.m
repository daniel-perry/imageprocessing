% finds the maxima in an accumulator image, returns the params of the maxima
% params:
%  accum - the accumulator image
%  theta - list of [theta_min, d_theta, theta_max]
%  rho - list of [rho_min, d_rho, rho_max]
function params = findmaxima( accum, theta, rho, percent )

max_val = max(accum(:));

thold = percent*max_val;

loc = accum >= thold;

count = sum(loc(:))

params = zeros(count,2);
index = 1;

for x=1:size(loc,1)
  for y=1:size(loc,2)
    if loc(x,y) > 0
      t = theta(1)+(x-1)*theta(2);
      r = rho(1)+(y-1)*rho(2);
      params(index,:) = [t,r];
      index = index + 1;
    end
  end
end

