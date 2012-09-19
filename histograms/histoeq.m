% takes a 2D array (or image) I as input and returns
% an image of the same type that has undergone histogram
% equalization using n bins and has a range of outputs 
% that spans the range between min and max.

% O - output histogram equalized image
function [O] = histoeq(I, n, min, max)

[h,bins] = histogram(I, n, min, max);

O = zeros(size(I));
imcdf = 0;
for (i=1:n-1)
	index = ((I>=bins(i)) .* (I<bins(i+1))) == 1;
	imcdf = imcdf + h(i);
	O(index) = max*imcdf;
end
% handle the last bin:
index = ((I>=bins(n)) .* (I<=max)) == 1;
imcdf = imcdf + h(n);
O(index) = max*imcdf;

O = uint8(O); % for imshow...




