% codebook_matches - find which codebooks match a patch and 
%                    return the list of indicated centers.
% params:
%  accum - hough accumulator
%  apatch - the patch to examine.
%  alocation - the patch location.
%  codebook - the codebook.
%  threshold - the cluster threshold
% return:
%  the hough accumulator
function accum = codebook_matches( accum, apatch, alocation, codebook, threshold )

matches = [];

for i=1:size(codebook,1)
  cluster_center = codebook{i,1};
  if ngc(cluster_center, apatch) > threshold
    cb_locs = codebook{i,2};
    for j=1:size(cb_locs,1)
      proposed_center = alocation + cb_locs(j,:);
      inside = (proposed_center > [0 0]) && (proposed_center <= size(accum);
      if inside
        accum( proposed_center(1), proposed_center(2) ) = accum( proposed_center(1), proposed_center(2) ) + 1;
      end
    end
  end
end

