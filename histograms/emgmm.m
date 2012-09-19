% Fit a GMM to the data using Expectation-Maximization
% NOTE: I wrote this is octave, and when I ran it in 
% matlab, I apparently don't have the statistics toolbox,
% so you may want to run this part in octave... if it
% doesn't work in matlab (as I couldn't test it in matlab).

% Seg - labeled segmentation over the image
% Thold - list of thresholds dividing each label group (gaussian)
% I - input image
% k - number of gaussians
% max_iters - max # iterations
function [Means,Variances,Mix] = emgmm( I , k , max_iters)

x = double(I(:)');
n = size(x,2);
size_of_x = size(x)

% initial mean:
means=unifrnd(min(x),max(x),[k,1]);
means

% initial variance
variances=unifrnd(1,5,[k,1]); 

% initial (even) mix
mix=ones(k,1);  
mix = mix ./ norm(mix,1); 

% initial membership 
membership = zeros(k,n);

% for checking convergence...
premeans = means;
prevariances = variances;
premix = mix;
iters = 0;

while( iters<max_iters )

	%======================
	% E-step (membership):
	%======================
	mixmat = mix * ones(1,n); % [mix mix ... mix]
	meanmat = means * ones(1,n); % [means means ... means]
	varmat = variances * ones(1,n); % [variances variances .. variances]
	xmat = ones(k,1) * x; % [x; x; ... x]
	membership = mixmat .* normpdf( xmat, meanmat, varmat );
	% normalize:
	normalizer = sum(membership,2); % k by 1
	normalizer = normalizer * ones(1,n); % k by n
	membership = membership ./ normalizer;


	%=======================
	% M-step (parameters):
	%======================
	normalizer = sum(membership,2) % total responsibility over all pts from each gaussian.
	means = sum((ones(k,1)*x) .* membership,2) ./ normalizer;
	dif = (ones(k,1)*x) - (means*ones(1,n));
	variances = sum(dif .* dif .* membership, 2) ./ normalizer;
	mix = normalizer ./ n;

	%====================
	% check convergence
	%====================
	mnorm = norm(premeans-means);
	vnorm = norm(prevariances-variances);
	mixnorm = norm(premix-mix);
  epsilon = 10^(-2);
	if( mnorm < epsilon && vnorm < epsilon && mixnorm < epsilon )
		break;
  end
	% save current params for next iteration...
	premeans = means;
	prevariances = variances;
	premix = mix;

  iters = iters + 1;
end

sprintf('iters=%d',iters);

Means = means;
Variances = variances;
Mix = mix;

% estimate intersection of gaussians:
%middle = (means(1)+means(2))/2 ;
%
%Thold = middle;
%Seg = I > Thold;
%
