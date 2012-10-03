function Mask = makeGauss1D(sigma)

radius = floor(3*sigma);
sideSize = 1+2*radius;

Mask = zeros(1,sideSize);

den = 1 / (sqrt(2*pi*sigma*sigma));
for i=1:sideSize
  x = i-radius-1;
  Mask(i) = den * exp( -0.5 * (x/sigma) * (x/sigma) );
end
%Mask = Mask / norm(Mask); % normalize
