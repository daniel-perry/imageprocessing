% Fit a GMM to the data using Expectation-Maximization
% params:
% I - input image
% k - number of gaussians
% max_iters - max # iterations
function [Means,Variances,Mix,Membership] = emgmm( I , k , max_iters)

x = double(I(:)');
n = size(x,2);

% initial mean:
%means=unifrnd(min(x),max(x),[k,1]);
%means=uniformrnd(min(x),max(x),[k,1]);
means = kmeans(I,k,max_iters); % initialize with kmeans result

% initial variance
%variances=unifrnd(1,5,[k,1]); 
%variances=uniformrnd(1,5,[k,1]);
variances=ones(k,1);

% initial (even) mix
mix = ones(k,1);  
mix = mix ./ norm(mix,1);

% initial membership 
membership = zeros(k,n);

% for checking convergence...
premeans = means
prevariances = variances
premix = mix
iters = 0;

for( iters=1:max_iters )

	%======================
	% E-step (membership):
	%======================
	mixmat = mix * ones(1,n); % [mix mix ... mix]
	meanmat = means * ones(1,n); % [means means ... means]
	varmat = variances * ones(1,n); % [variances variances .. variances]
	xmat = ones(k,1) * x; % [x; x; ... x]
	%membership = mixmat .* normpdf( xmat, meanmat, varmat );
	membership = mixmat .* normalpdf( xmat, meanmat, varmat );
	% normalize:
	mem_normalizer = sum(membership,1); % n by 1
	mem_normalizer = ones(k,1) * mem_normalizer; %* ones(1,n); % k by n
	membership = membership ./ mem_normalizer;
  %membership( mem_normalizer <= eps ) = 0 % hack to avoi NaNs


	%=======================
	% M-step (parameters):
	%======================
	normalizer = sum(membership,2) % total responsibility over all pts from each gaussian.
  memb_normed = membership ./ (normalizer*ones(1,n));
	means = sum((ones(k,1)*x) .* memb_normed,2) ./ normalizer
	%means = sum((ones(k,1)*x) .* membership,2) ./ normalizer
  mn2 = memb_normed .* memb_normed;
  mn2 = ones(k,1) ./ (ones(k,1)-sum(mn2,2));
	dif = (ones(k,1)*x) - (means*ones(1,n));
	variances = mn2 .* sum(dif .* dif .* memb_normed, 2) 
	%variances = sum(dif .* dif .* membership, 2) ./ normalizer
	mix = normalizer ./ n

	%====================
	% check convergence
	%====================
	mnorm = norm(premeans-means);
	vnorm = norm(prevariances-variances);
	mixnorm = norm(premix-mix);
  epsilon = 10^(-3);
	if( mnorm < epsilon && vnorm < epsilon && mixnorm < epsilon )
		break;
  end
	% save current params for next iteration...
	premeans = means;
	prevariances = variances;
	premix = mix;

  iters = iters + 1;
end

sprintf('iters=%d',iters)

Means = means;
Variances = variances;
Mix = mix;
Membership = membership;

% estimate intersection of gaussians:
%middle = (means(1)+means(2))/2 ;
%
%Thold = middle;
%Seg = I > Thold;
%
