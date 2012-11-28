% runs the hough transform code

% images
shapes_fn = 'images/shapes.png';
shapes = imread(shapes_fn);
runway_fn = 'images/runway.png';
runway = imread(runway_fn);

addPath('edges'); % for edge code from assignment 2

shapes_edge = edgeMap( shapes );
imwrite(shapes_edge, 'images/shapes_edge.png');
shapes_theta = [0,pi/1000,pi/2];
[shapes_accum,shapes_rho] = hough( shapes_edge , shapes_theta );
imwrite(rescaleDiffImage(shapes_accum), 'images/shapes_accum.png');
shapes_rho = shapes_rho
thold = .9;
params = findmaxima( shapes_accum, shapes_theta, shapes_rho, thold );
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_lines_%0.1f.png',thold));
thold = .7;
params = findmaxima( shapes_accum, shapes_theta, shapes_rho, thold );
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_lines_%0.1f.png',thold));

subplot(2,2,1);
imshow(shapes);
subplot(2,2,2);
imshow(shapes_edge);
subplot(2,2,3);
imshow(rescaleDiffImage(shapes_accum));
subplot(2,2,4);
imshow(shapes_lines);

%{

runway_edge = edgeMap( runway );
imwrite(rescaleDiffImage(runway_edge), 'images/runway_edge.png');
runway_theta = [0,pi/1000,pi/2];
[runway_accum,runway_rho] = hough( runway_edge , runway_theta );
imwrite(rescaleDiffImage(runway_accum), 'images/runway_accum.png');
runway_rho = runway_rho

subplot(3,1,1);
imshow(runway);
subplot(3,1,2);
imshow(rescaleDiffImage(runway_edge));
subplot(3,1,3);
imshow(rescaleDiffImage(runway_accum));

%}
