% normalizes and pads an image to be used
% in stencil matching.
function Out = makeStencil(In)

% normalize
tmp = double(In);
tmp = tmp / norm(tmp(:));

% pad to make square and odd sided
side = max(size(tmp));
if mod(side,2) == 0
  side = side + 1;
end

Out = zeros(side,side);
x_side = floor(size(tmp,1)/2);
size_tmp = size(tmp,1);
x_space = floor((side - size(tmp,1))/2);
y_space = floor((side - size(tmp,2))/2);

Out(1+x_space:x_space+size(tmp,1), 1+y_space:y_space+size(tmp,2)) = tmp;

