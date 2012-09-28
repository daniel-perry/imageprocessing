% convolves a mask with an image
% In - input image
% Mask - mask to convolve (must be square and odd-sided)

function Out = convolve( In, Mask )

% we want a square, odd-sided mask:
mask_size = size(Mask);
if mask_size(1) != mask_size(2)
	sprintf('mask must be sqare! not %d x %d',mask_size(1),mask_size(2))
	return;
end
if mod(mask_size(1) , 2) == 0
	sprintf('mask side must be odd! not %d',mask_size(1))
	return;
end

Mask = Mask'; %definition of convolution

border = floor(mask_size(1) / 2);

image_size = size(In);

Out = zeros(image_size(1)-2*border, image_size(2)-2*border);

for r=1+border:image_size(1)-border
	for c=1+border:image_size(2)-border
		section = In(r-border:r+border,c-border:c+border);
		result = section .* Mask;
		Out(r-border,c-border) = sum(result(:));
	end
end

Out = uint8(Out);
