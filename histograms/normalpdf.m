% multivariate normal distribution pdf
% x - point
% m - mean
% sd - standard deviation
function p = normalpdf(x,m,sd)

v = sd.*sd;
o = ones(size(sd));
scale_part = o ./ (sd * sqrt(2*pi));
e_part = exp( -0.5 * ( (x-m).^2 ./ v ) );
p =  scale_part .* e_part;

