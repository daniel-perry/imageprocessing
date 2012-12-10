% ngc - normalized greyscale correlation
% params:
% p1,2 - two patches to be correlated
% return:
% correlation - the ngc correlation score
function correlation = ngc( p1, p2 )

m1 = mean( p1(:) );
m2 = mean( p2(:) );

p1_centered = p1-(m1*ones(size(p1)));
p2_centered = p2-(m2*ones(size(p2)));

num = p1_centered * p2_centered';
den = sqrt( (p1_centered .* p1_centered) * (p2_centered .* p2_centered)' );

correlation = num/den;

