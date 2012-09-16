
% Seg - labeled segmentation over the image
% Thodl - list of thresholds dividing each label group (gaussian)
% I - input image
% k - number of gaussians
% max_iters - max # iterations
function [Seg,Thold] = emgmm( I , k , max_iters)

x = I(:);

means=stdnormal_rnd(k,1); 
variances=stdnormal_rnd(k,1); 
mix=stdnormal_rnd(k,1); 
mix = mix ./ norm(mix,2);

membership = zeros(n,k);

for( iters=1:max_iters )

	% E-step (membership):
	for( pt=1:size(x,1) )
		normalizer = 0;
		for( cluster=1:k )
			membership(pt,cluster) = mix(cluster) * lognpdf(x(pt),means(cluster),variances(cluster));
			normalizer += membership(pt,cluster);
		end
		membership(pt,:) ./= normalizer;
	end

	% M-step (parameters):
	n = sum(membership,1); % total responsibility over all pts from each gaussian.

	

end
