% convolves a separable 1D mask with an image in both directions
% In - input image
% Mask - mask to convolve (must be 1xN, where N is ODD)

function Out = convolve1D( In, Mask )

mask_size = size(Mask);

% check if it's a 1D mask
if mask_size(1) ~= 1 && mask_size(2) ~= 1
 	sprintf('mask must be 1D! not %d x %d',mask_size(1),mask_size(2))
 	return;
end
if mod(max(mask_size),2) == 0
	sprintf('mask must be ODD length! not %d',max(mask_size));
	return;
end

In = double(In);
Mask = double(Mask);

image_size = size(In);
border = floor(max(mask_size) / 2);

if mask_size(2) > 1 % row mask vector

  Out = zeros(image_size(1)-2*border, image_size(2)); % cutting off border on sides

  for r=1+border:image_size(1)-border
  	for c=1:image_size(2)
  		section = In(r-border:r+border,c); % col vector
  		%result = section .* Mask;
  		%Out(r-border,c) = sum(result(:));
  		Out(r-border,c) = Mask * section; % inner product
  	end
  end

else % col mask vector

  Out = zeros(image_size(1), image_size(2)-2*border);

  for r=1:image_size(1)
  	for c=1+border:image_size(2)-border
  		section = In(r,c-border:c+border); % row vector
  		%result = section .* Mask;
  		%Out(r,c-border) = sum(result(:));
  		Out(r,c-border) = section * Mask; % inner product
  	end
  end

end

