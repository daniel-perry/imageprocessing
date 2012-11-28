% runs the hough transform code

% images
shapes_fn = 'images/edges-lines-orig.png';
shapes = imread(shapes_fn);
runway_fn = 'images/mnn4-runway-Ohio.jpg';
runway = imread(runway_fn);

addpath('../spatial_filtering') % for edge filter

shapes_edge = edgeMap( shapes );
shapes_accum = hough( shapes_edge , [0,pi/100,pi/2] );

subplot(3,1,1);
imshow(shapes);
subplot(3,1,2);
imshow(shapes_edge);
subplot(3,1,3);
imshow(rescaleDiffImage(shapes_accum));

