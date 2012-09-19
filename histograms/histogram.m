% takes a 2D array (image) I as input (integers or floats) 
% and returns a 1D array of floats (length n) that gives the 
% relative frequency of the occurance of greyscale values in each of the n
% bins that equally (to within integer round off) divide the range of (integer) 
% values between min and max

% h = histogram percents
% bins = lower bin edges
function [h,bins] = histogram(I, n, min, max)
I = I(:);

range = max - min;
drdb = range / double(n); % dr/db - change in range per bin

h = zeros(n,1);
bins = zeros(n,1);
for i=1:n
	% note: while the instructions say "within integer round off" I'm leaving
	%       this as float bin edges, to handle the potential float input
	%       ie - say the input was a probability image.
	low = min + (i-1)*drdb; 
	high = min + i*drdb;
	h(i) = sum( (I>=low) .* (I<high) );
  bins(i) = low;
end

h(n) = h(n) + sum( (I>=(n*drdb)) .* (I<=max) ); % include anything we may have missed in the last bin.

h = h ./ sum(h); % "relative frequency"  

