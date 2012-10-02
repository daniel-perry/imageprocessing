function Mask = makeGauss1D(sideSize, sigma)

Mask = zeros(1,sideSize);
radius = floor(sideSize/2);

den = 1 / (sqrt(2*pi*sigma*sigma));
for i=1:sideSize
  x = i-radius-1;
  Mask(i) = den * exp( -0.5 * (x/sigma) * (x/sigma) );
end
Mask = Mask / norm(Mask); % normalize
