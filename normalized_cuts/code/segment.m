% function [S] = segment(imsize,evec)
% segment the image given the eigenvector solution to the continuous ncut problem.
% params:
%   imsize - the image size.
%   evec - the eigenvector solution
% return:
%   S - the binary segmentation
function [S] = segment(imsize,evec)

% simple approach - use the median value to decided
thold = median(evec)
S = evec > thold;
S = reshape(S, imsize);

