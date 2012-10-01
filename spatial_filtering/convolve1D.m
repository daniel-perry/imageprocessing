% convolves a separable 1D mask with an image in both directions
% In - input image
% Mask - mask to convolve (must be 1xN, where N is ODD)

function Out = convolve1D( In, Mask )

mask_size = size(Mask);
% check if it's a 1D mask
if mask_size(1) != 1 && mask_size(2) != 1
 	sprintf('mask must be 1D! not %d x %d',mask_size(1),mask_size(2))
 	return;
end
if mod(max(mask_size),2) == 0
	sprintf('mask must be ODD length! not %d',max(mask_size));
	return;
end

Mask = reshape(Mask, [1,max(mask_size)]); % row vector
Mask = reverse(Mask); %definition of convolution (ie transposing in 1D..)
mask_size = size(Mask);

border = floor(mask_size(1) / 2);

image_size = size(In);

OutTmp = zeros(image_size(1)-2*border, image_size(2)); % cutting off border on sides

for r=1+border:image_size(1)-border
	for c=1:image_size(2)
		section = In(r-border:r+border,c);
		result = section .* Mask;
		OutTmp(r-border,c) = sum(result(:));
	end
end

Mask = Mask'; % column vector
image_size = size(OutTmp);
Out = zeros(image_size(1)-2*border, image_size(2)-2*border);
for r=1:image_size(1)
	for c=1+border:image_size(2)-border
		section = OutTmp(r,c-border:c+border);
		result = section .* Mask;
		Out(r,c-border) = sum(result(:));
	end
end

Out = uint8(Out);
