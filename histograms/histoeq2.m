
% same as histoeq but with alpha parameter to blend...
function [O] = histoeq2(I, n, min, max, alpha)

[h,bins] = histogram(I, n, min, max);

O = zeros(size(I));
imcdf = 0;
for (i=1:n-1)
	index = ((I>=bins(i)) .* (I<bins(i+1))) == 1;
	imcdf = imcdf + h(i);
	O(index) = alpha*max*imcdf+(1-alpha)*bins(i);
end
% handle the last bin:
index = ((I>=bins(n)) .* (I<=max)) == 1;
imcdf = imcdf + h(n);
O(index) = max*imcdf;

O = uint8(O); % for imshow...

