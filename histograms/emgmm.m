% Fit a GMM to the data using Expectation-Maximization

% Seg - labeled segmentation over the image
% Thodl - list of thresholds dividing each label group (gaussian)
% I - input image
% k - number of gaussians
% max_iters - max # iterations
function [Seg,Thold] = emgmm( I , k , max_iters)

x = I(:)';
n = size(I,2);

means=stdnormal_rnd(k,1); 
variances=stdnormal_rnd(k,1); 
mix=stdnormal_rnd(k,1); 
mix = mix ./ norm(mix,2);

membership = zeros(k,n);

premeans = means;
prevariances = variances;
premix = mix;

iters = 0;

while( iters<max_iters )

	% E-step (membership):
	for( pt=1:size(x,2) )
		normalizer = 0;
		for( cluster=1:k )
			membership(cluster,pt) = mix(cluster) * lognpdf(x(pt),means(cluster),variances(cluster));
			normalizer += membership(cluster,pt);
		end
		membership(:,pt) ./= normalizer;
	end

	% M-step (parameters):
	n = sum(membership,1); % total responsibility over all pts from each gaussian.
	means = sum((ones(k,1)*x) .* membership,1) ./ n;
	dif = ones(k,1)*x - means*ones(size(x));
	variances = sum(dif .* dif .* membership, 1) ./ n;
	mix = n ./ size(x,2);

	mnorm = norm(premeans-means);
	vnorm = norm(prevariances-variances);
	mixnorm = norm(premix-mix);
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

