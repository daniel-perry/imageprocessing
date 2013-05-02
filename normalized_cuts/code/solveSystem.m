% function [evec] = solveSystem(W,D)
% finds the second to smallest eigenvector, 
function [evec] = solveSystem(W,D)

Dinv = sqrt(inv(D));  % diagonal - so just dinv_ii = 1/d_ii  .. this is a quick way to do that..

M = Dinv * (D - W) * Dinv; % system to decompose, minimizes the Rayleigh quotient.

image(M*256)

[evecs,evals] = eigs(M,2,0);  % find the two smallest eigenvec

evec = evecs(:,1); 
