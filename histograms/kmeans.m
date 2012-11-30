% kmeans
% I - input image
% k - number of clusters
% max_iters - max # iterations
function [Means,Membership] = kmeans( I , k , max_iters)

x = double(I(:)');
n = size(x,2);

% initial mean:
%means=unifrnd(min(x),max(x),[k,1]);
means=uniformrnd(min(x),max(x),[k,1]);

% initial membership 
membership = zeros(k,n);

% for checking convergence...
premeans = means;

for( iters=1:max_iters )

	%======================
	% E-step (membership):
	%======================
	meanmat = means * ones(1,n); % [means means ... means]
	xmat = ones(k,1) * x; % [x; x; ... x]
  bias = zeros(k,1);
  epsilon = 1e-10;
  for i=1:k
    bias(i) = epsilon;
    epsilon = epsilon + 1e-11;
  end
  bias = bias*ones(1,size(x,2)); % avoid equidistant points... 

  membership = abs(meanmat-xmat) + bias;
  memb_min = min(membership);
  memb_min = ones(k,1) * memb_min; 
  membership = membership == memb_min;

	%=======================
	% M-step (parameters):
	%======================
  xselected = zeros(size(xmat));
  xselected(membership) = xmat(membership);
  count = sum(membership,2);
  means = sum(xselected,2) ./ count;

	%====================
	% check convergence
	%====================
	mnorm = norm(premeans-means);
  epsilon = 10^(-3);
	if( mnorm < epsilon )
		break;
  end
	% save current params for next iteration...
	premeans = means;
end

sprintf('iters=%d',iters)

Means = means;
Membership = membership;

