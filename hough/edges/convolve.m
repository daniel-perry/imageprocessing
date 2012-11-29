% convolves a mask with an image
% In - input image
% Mask - mask to convolve (must be either square and odd-sided, OR, 1xN where N)

function Out = convolve( In, Mask )

mask_size = size(Mask);
if mask_size(1) == 1 || mask_size(2) == 1 
	OutTmp = convolve1D(In, Mask);
	Out = convolve1D(OutTmp, Mask');
else
	Out = convolve2D(In, Mask);
end

Out = uint8(Out);
