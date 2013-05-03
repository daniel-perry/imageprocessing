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

F = double(im(:));
if length(size(im)) > 2 % color
  im = rgb2hsv(im);
  F = double(reshape(F, size(im,1)*size(im,2), 3));
  tmp = F;
  % compute color feature used in paper:
  F(:,1) = tmp(:,3); % v
  F(:,2) = tmp(:,3) .* tmp(:,2) .* sin(tmp(:,1)); % v * s * sin(h)
  F(:,3) = tmp(:,3) .* tmp(:,2) .* cos(tmp(:,1)); % v * s * cos(h)
end
flen = size(F,1);

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

loc = zeros(size(im,1),size(im,2),2);
loc(:,:,1) = x;
loc(:,:,2) = y;
xy = reshape(loc, flen, 2);

tic;
W = sparse(flen,flen); 
%arrayfun(@buildSparse, 1:flen );

for i=1:flen
  for j=i:flen % symmetric
    difference = xy(i,:)-xy(j,:);
    distance = norm(difference);
    if distance <= r
      Fdiff = F(i)-F(j);
      Fdiff = Fdiff' * Fdiff; % 2-norm squared
      W(i,j) = exp(-(distance+Fdiff)/sigma);
    end
  end
  if mod(i,100) == 0 % poor man's progress bar..
    progress = 100 * (i/flen)
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

end %function


% for building the sparse matrix - but turns out arrayfun() is slower than for loops..
%function [xi,yi,w] = buildSparse(ind)
function buildSparse(ind)
  global F;
  global xy;
  is = ind*ones(flen-(ind-1),1); % index repeated 
  js = (ind:flen)'; % subloop indices
  arrayfun( @buildSparse2, is, js);
end % function

%function [xi,yi,w] = buildSparse2(i,j)
function buildSparse2(i,j)
  global F;
  global xy;
  global W;
  global radius;
  sigma = radius/3;
  difference = xy(i,:)-xy(j,:);
  distance = norm(difference);
  if distance <= radius
    Fdiff = F(i)-F(j);
    Fdiff = Fdiff' * Fdiff; % 2-norm squared
    W(i,j) = exp(-(distance+Fdiff)/sigma);
  end
end % function

