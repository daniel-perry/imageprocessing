% runs the hough transform code

% images
shapes_fn = 'images/shapes.png';
shapes = imread(shapes_fn);
runway_fn = 'images/runway.png';
runway = imread(runway_fn);

addpath('../spatial_filtering') % for edge filter

shapes_edge = edgeMap( shapes );
imwrite(shapes_edge, 'images/shapes_edge.png');
shapes_theta = [0,pi/1000,pi/2];
[shapes_accum,shapes_rho] = hough( shapes_edge , shapes_theta );
imwrite(shapes_accum, 'images/shapes_accum.png');
shapes_rho = shapes_rho

subplot(3,1,1);
imshow(shapes);
subplot(3,1,2);
imshow(shapes_edge);
subplot(3,1,3);
imshow(rescaleDiffImage(shapes_accum));

