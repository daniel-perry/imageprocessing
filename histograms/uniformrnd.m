% return a matrix of uniform random variables
% between minval and maxval
% of size dim
function r = uniformrnd( minval, maxval, dim )
 r = minval + (maxval-minval).*rand(dim);
