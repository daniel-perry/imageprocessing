% Fit a GMM to the data using Expectation-Maximization

% Seg - labeled segmentation over the image
% Thodl - list of thresholds dividing each label group (gaussian)
% I - input image
% k - number of gaussians
% max_iters - max # iterations
function [Seg,Thold] = emgmm( I , k , max_iters)

x = double(I(:)');
n = size(x,2);
size_of_x = size(x)

means=stdnormal_rnd(k,1); 

means *= 10
variances=stdnormal_rnd(k,1); 
minvar = min(variances);
if( minvar < 0)
  variances -= minvar; %scale to positive..
end
variances *= 10;
mix=stdnormal_rnd(k,1); 
minmix = min(mix);
if( minmix < 0 )
	mix -= minmix; %scale to positive..
end
mix = mix ./ norm(mix,1);

membership = zeros(k,n);

premeans = means;
prevariances = variances;
premix = mix;

iters = 0;

while( iters<max_iters )

	% E-step (membership):
	summix = sum(mix)
	mixmat = mix * ones(1,n); % [mix mix ... mix]
	meanmat = means * ones(1,n); % [means means ... means]
	varmat = variances * ones(1,n); % [variances variances .. variances]
	xmat = ones(k,1) * x; % [x; x; ... x]
	sumxmat = sum(xmat(:))
	summeamat = sum(meanmat(:))
	sumvarmat = sum(varmat(:))
	summixmat = sum(mixmat(:))
	membership = mixmat .* normpdf( xmat, meanmat, varmat );
	summemb = sum(membership(:))
	% normalize:
	normalizer = sum(membership,1); % 1 by n
	minnormalizer = min(normalizer)
	normalizer = ones(k,1) * normalizer; % k by n
	membership ./= normalizer;
	summemb = sum(membership(:))

	%for( pt=1:size(x,2) )
	%	normalizer = 0;
	%	for( cluster=1:k )
	%		membership(cluster,pt) = mix(cluster) * normpdf(x(pt),means(cluster),variances(cluster));
	%		normalizer += membership(cluster,pt);
	%	end
	%	membership(:,pt) ./= normalizer;
	%end

	% M-step (parameters):
	normalizer = sum(membership,2) % total responsibility over all pts from each gaussian.
	means = sum((ones(k,1)*x) .* membership,2) ./ normalizer;
	dif = (ones(k,1)*x) - (means*ones(1,n));
	variances = sum(dif .* dif .* membership, 2) ./ normalizer;
	mix = normalizer ./ n;

	mnorm = norm(premeans-means)
	mpresum = sum(premeans)
	msum = sum(means)
	premeans = means;
	vnorm = norm(prevariances-variances)
	prevariances = variances;
	mixnorm = norm(premix-mix)
	premix = mix;
	if( mnorm < 1 && vnorm < 1 && mixnorm < 1 )
		break;
  end

  iters+=1
end

sprintf("iters=%d",iters);

% estimate intersection of gaussians:
middle = (means(0)+means(1))/2;

Thold = middle;
Seg = I > Thold;

