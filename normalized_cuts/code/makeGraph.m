% function [W,D] = makeGraph(im, r)
% generate the W and D matrices for the normalized graph cuts algorithm
% params:
%   im - the original image
%   r - radius of pixel neighborhood
% returns:
%   W - the weights of the graph edges between nodes i,j
%   D - diagonal matrix of incoming weights to node i
function [W,D] = makeGraph(im, r)

sigma = r/3;

F = im(:);
%tmp = ones(size(F))';

%Fdiff = F * tmp - tmp' * F';
%Fdiff = Fdiff .* Fdiff;
%W = exp( - Fdiff / sigma );

x = 1:size(im,1);
y = 1:size(im,2);

tmp = ones(1,size(im,2));
x = x' * tmp;
tmp = ones(1,size(im,1));
y = tmp' * y;

dist = zeros(size(im,1),size(im,2),2);
dist(:,:,1) = x;
dist(:,:,2) = y;
dist = reshape(dist, length(F), 2);

%dist2 = zeros(length(F),length(F));
tic;
W = sparse(length(F),length(F)); 
for i=1:length(F)
  for j=i:length(F) % symmetric
    difference = dist(i,:)-dist(j,:);
    distance = norm(difference);
    if distance <= r
      Fdiff = F(i)-F(j);
      Fdiff = Fdiff' * Fdiff; % 2-norm squared
      W(i,j) = exp(-(distance+Fdiff)/sigma);
    end
  end
  if mod(i,100) == 0 % poor man's progress bar..
    progress = 100 * (i/length(F))
  end
end
toc

%dist = exp(-(dist2)/sigma) .* (dist2<=r);
%W = sparse(W .* dist);

%D = sparse( (sum(W,2) * ones(1,size(W,1))) .* eye(size(W)) );
d  = sum(W,2);

% need full W and D matrices:
D = sparse(size(W,1),size(W,2));
W = W + W';
for i=1:size(D,1)
  D(i,i) = d(i);
  W(i,i) = W(i,i)/2; % fix diagonal (from added transpose)
end

