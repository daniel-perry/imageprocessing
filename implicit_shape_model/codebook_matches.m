% codebook_matches - find which codebooks match a patch and 
%                    return the list of indicated centers.
% params:
%  accum - hough accumulator
%  apatch - the patch to examine.
%  alocation - the patch location.
%  codebook_pos - the codebook of positive examples.
%  codebook_neg - the codebook of negative examples.
%  threshold - the cluster threshold
%  amount - amount to accumulate from codebook match
% return:
%  the hough accumulator
function accum = codebook_matches( accum, apatch, alocation, codebook_pos, codebook_neg, threshold , amount )

matches = [];

for i=1:size(codebook_pos,1)
  cluster_center = codebook_pos{i,1};
  correlation = ngc(cluster_center, apatch);
  if correlation > threshold
    % check if a negative codebook (background) has a better correlation with this patch:
    correlation_neg = threshold;
    for j=1:size(codebook_neg,1)
      cc = codebook_neg{j,1};
      cor = ngc(cc, apatch);
      if cor > correlation_neg
        correlation_neg = cor;
      end
    end
    cb_locs = codebook_pos{i,2};
    for j=1:size(cb_locs,1)
      proposed_center = ceil(alocation + cb_locs(j,:));
      inside = (proposed_center > [0 0]) .* (proposed_center <= size(accum));
      if inside
        correlation_neg = correlation_neg - threshold;
        incr_amt = amount * (correlation-threshold);
        if correlation_neg > 0
          incr_amt = amount * (correlation-threshold-correlation_neg);
        else
          incr_amt = amount * (correlation-threshold);
        end
        accum( proposed_center(1), proposed_center(2) ) = accum( proposed_center(1), proposed_center(2) ) + incr_amt;
      end
    end
  end
end

