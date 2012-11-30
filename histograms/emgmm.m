% Fit a GMM to the data using Expectation-Maximization
% params:
% I - input image
% k - number of gaussians
% max_iters - max # iterations
function [Means,Variances,Mix,Likelihood,Membership] = emgmm( I , k , max_iters)

x = double(I(:)');
n = size(x,2);

% initial mean:
%means=unifrnd(min(x),max(x),[k,1]);
%means=uniformrnd(min(x),max(x),[k,1]);
means = kmeans(I,k,max_iters) % initialize with kmeans result

% initial variance
%variances=unifrnd(1,5,[k,1]); 
%variances=uniformrnd(1,5,[k,1]);
variances=ones(k,1);

% initial (even) mix
mix = ones(k,1);  
mix = mix ./ norm(mix,1);

% initial membership 
[membership,likelihood] = expectation( x, means, variances, mix );

% for checking convergence...
prelike = likelihood
iters = 0;

epsilon = 1e-10;

for( iters=1:max_iters )

	%=======================
	% M-step (parameters):
	%======================
  [means,variances,mix] = maximization( x, membership );

	%======================
	% E-step (membership):
	%======================
  [membership,likelihood] = expectation( x, means, variances, mix );

	%====================
	% check convergence
	%====================
  diff = likelihood - prelike;
  if( abs(diff) < epsilon )
    break;
  end
	% save current params for next iteration...
  prelike = likelihood;
  iters = iters + 1;
end

iters=iters

Means = means;
Variances = variances;
Mix = mix;
Membership = membership;
Likelihood = likelihood;

% calculate membership given the GMM parameters:
function [membership,likelihood] = expectation(x,means,variances,mix)
  n = size(x,2);
  k = size(means,1);
	mixmat = mix * ones(1,n); % [mix mix ... mix]
	meanmat = means * ones(1,n); % [means means ... means]
	varmat = variances * ones(1,n); % [variances variances .. variances]
	xmat = ones(k,1) * x; % [x; x; ... x]
	membership = mixmat .* normalpdf( xmat, meanmat, varmat );
  likelihood = sum(membership(:)) / n; % avg likelihood
	% normalize:
	mem_normalizer = sum(membership,1); % n by 1
	mem_normalizer = ones(k,1) * mem_normalizer; %* ones(1,n); % k by n
	membership = membership ./ mem_normalizer;
  membership( mem_normalizer <= eps ) = 0; % hack to avoid NaNs

% calculate the GMM parameters given the membership
function [means,variances,mix] = maximization( x, membership )
  n = size(x,2);
  k = size(membership,1);
	normalizer = sum(membership,2); % total responsibility over all pts from each gaussian.
  memb_normed = membership ./ (normalizer*ones(1,n));
	%means = sum((ones(k,1)*x) .* memb_normed,2) ./ normalizer;
	means = sum((ones(k,1)*x) .* membership,2) ./ normalizer;
  mn2 = memb_normed .* memb_normed;
  mn2 = ones(k,1) ./ (ones(k,1)-sum(mn2,2));
	dif = (ones(k,1)*x) - (means*ones(1,n));
	%variances = mn2 .* sum(dif .* dif .* memb_normed, 2) 
	variances = sum(dif .* dif .* membership, 2) ./ normalizer;
	mix = normalizer ./ n;


