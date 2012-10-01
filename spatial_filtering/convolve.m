% convolves a mask with an image
% In - input image
% Mask - mask to convolve (must be either square and odd-sided, OR, 1xN where N)

function Out = convolve( In, Mask )

mask_size = size(In);
if mask_size(1) == 1 || mask_size(2) == 1 
	Out = convolve1D(In, Mask);
else
	Out = convolve2D(In, Mask);
end

