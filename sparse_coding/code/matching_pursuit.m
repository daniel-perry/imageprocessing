%function [g] = matching_pursuit(f, D)
%params:
% f - original image
% D - sparse dictionary
function [g] = matching_pursuit(f, D)

R = f;

gamma = []
for n=1:100
  maxg = 0
  maxi = 0
  for i=1:size(D,2)
    if sum(gamma == i)>0
      g = D(:,i);
    end
  end
end

