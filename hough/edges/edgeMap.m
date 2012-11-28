% calculate the edge map of an image,
% which consists of the magnitude of the
% gradient at each pixel.

function Out = edgeMap(In)

dx = convolve1D(In, makeDiff1D());
dy = convolve1D(In, makeDiff1D()');

% crop dx,dy so they are the same size:
y_border_for_dx = (size(dx,2) - size(dy,2))/2;
x_border_for_dy = (size(dy,1) - size(dx,1))/2;

dx = dx(:,y_border_for_dx:size(dy,2));
dy = dy(x_border_for_dy:size(dx,1),:);

Out = sqrt( dx.*dx + dy.*dy );
