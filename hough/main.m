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
shapes_accum_rescaled = rescaleDiffImage(shapes_accum);
imwrite(shapes_accum_rescaled, 'images/shapes_accum.png');
shapes_rho = shapes_rho
thold = .9;
params = findmaxima( shapes_accum, shapes_theta, shapes_rho, thold );
shapes_accum_points = drawpoints( shapes_accum_rescaled, params, shapes_theta, shapes_rho );
imwrite(shapes_accum_points, sprintf('images/shapes_accum_points_%0.1f.png',thold));
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_lines_%0.1f.png',thold));
thold = .7;
params = findmaxima( shapes_accum, shapes_theta, shapes_rho, thold );
shapes_accum_points = drawpoints( shapes_accum_rescaled, params, shapes_theta, shapes_rho );
imwrite(shapes_accum_points, sprintf('images/shapes_accum_points_%0.1f.png',thold));
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_lines_%0.1f.png',thold));
% blurring accumulator
thold = .9;
shapes_accum_blurred = convolve(shapes_accum, makeGauss1D(1));
shapes_accum_blurred_rescaled = rescaleDiffImage(shapes_accum_blurred);
imwrite(shapes_accum_blurred_rescaled, 'images/shapes_accum_blurred.png');
params = findmaxima( shapes_accum_blurred, shapes_theta, shapes_rho, thold );
shapes_accum_points = drawpoints( shapes_accum_blurred_rescaled, params, shapes_theta, shapes_rho );
imwrite(shapes_accum_points, sprintf('images/shapes_accum_blurred_points_%0.1f.png',thold));
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_blurred_lines_%0.1f.png',thold));
thold = .95;
shapes_accum_blurred = convolve(shapes_accum, makeGauss1D(1));
shapes_accum_blurred_rescaled = rescaleDiffImage(shapes_accum_blurred);
imwrite(shapes_accum_blurred_rescaled, 'images/shapes_accum_blurred.png');
params = findmaxima( shapes_accum_blurred, shapes_theta, shapes_rho, thold );
shapes_accum_points = drawpoints( shapes_accum_blurred_rescaled, params, shapes_theta, shapes_rho );
imwrite(shapes_accum_points, sprintf('images/shapes_accum_blurred_points_%0.2f.png',thold));
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_blurred_lines_%0.2f.png',thold));
% decremented accumulator
shapes_theta = [0,pi/1000,pi/2];
[shapes_accum_decr,shapes_rho] = hough_decrement( shapes_edge , shapes_theta );
shapes_accum_decr_rescaled = rescaleDiffImage(shapes_accum_decr);
imwrite(shapes_accum_decr_rescaled, 'images/shapes_accum_decr.png');
shapes_rho = shapes_rho
thold = .9;
params = findmaxima( shapes_accum_decr, shapes_theta, shapes_rho, thold );
shapes_accum_decr_points = drawpoints( shapes_accum_decr_rescaled, params, shapes_theta, shapes_rho );
imwrite(shapes_accum_decr_points, sprintf('images/shapes_accum_decr_points_%0.1f.png',thold));
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_decr_lines_%0.1f.png',thold));
thold = .7;
params = findmaxima( shapes_accum_decr, shapes_theta, shapes_rho, thold );
shapes_accum_decr_points = drawpoints( shapes_accum_decr_rescaled, params, shapes_theta, shapes_rho );
imwrite(shapes_accum_decr_points, sprintf('images/shapes_accum_decr_points_%0.1f.png',thold));
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_decr_lines_%0.1f.png',thold));

%{
subplot(2,3,1);
imshow(shapes);
subplot(2,3,2);
imshow(shapes_edge);
subplot(2,3,3);
imshow(rescaleDiffImage(shapes_accum));
subplot(2,3,4);
imshow(shapes_lines);
subplot(2,3,5);
imshow(shapes_accum_points);
%}

runway_edge = edgeMap( runway );
imwrite(rescaleDiffImage(runway_edge), 'images/runway_edge_orig.png');
[runway_accum,runway_rho] = hough( runway_edge , runway_theta );
imwrite(rescaleDiffImage(runway_accum), 'images/runway_accum_orig.png');
re_max = max(runway_edge(:));
re_match = runway_edge > .3*re_max;
runway_edge( ~re_match ) = 0;
imwrite(rescaleDiffImage(runway_edge), 'images/runway_edge.png');
runway_theta = [0,pi/1000,pi/2];
[runway_accum,runway_rho] = hough( runway_edge , runway_theta );
runway_accum_rescaled = rescaleDiffImage(runway_accum);
imwrite(runway_accum_rescaled, 'images/runway_accum.png');
runway_rho = runway_rho

thold = .9;
params = findmaxima( runway_accum, runway_theta, runway_rho, thold );
runway_accum_points = drawpoints( runway_accum_rescaled, params, runway_theta, runway_rho );
imwrite(runway_accum_points, sprintf('images/runway_accum_points_%0.2f.png',thold));
runway_lines = drawlines( runway, params );
imwrite(runway_lines, sprintf('images/runway_lines_%0.2f.png',thold));
thold = .5;
params = findmaxima( runway_accum, runway_theta, runway_rho, thold );
runway_accum_points = drawpoints( runway_accum_rescaled, params, runway_theta, runway_rho );
imwrite(runway_accum_points, sprintf('images/runway_accum_points_%0.2f.png',thold));
runway_lines = drawlines( runway, params );
imwrite(runway_lines, sprintf('images/runway_lines_%0.2f.png',thold));
% blurring accumulator
thold = .9;
runway_accum_blurred = convolve(runway_accum, makeGauss1D(1));
runway_accum_blurred_rescaled = rescaleDiffImage(runway_accum_blurred);
imwrite(runway_accum_blurred_rescaled, 'images/runway_accum_blurred.png');
params = findmaxima( runway_accum_blurred, runway_theta, runway_rho, thold );
runway_accum_points = drawpoints( runway_accum_blurred_rescaled, params, runway_theta, runway_rho );
imwrite(runway_accum_points, sprintf('images/runway_accum_blurred_points_%0.1f.png',thold));
runway_lines = drawlines( runway, params );
imwrite(runway_lines, sprintf('images/runway_blurred_lines_%0.1f.png',thold));
thold = .95;
runway_accum_blurred = convolve(runway_accum, makeGauss1D(1));
runway_accum_blurred_rescaled = rescaleDiffImage(runway_accum_blurred);
imwrite(runway_accum_blurred_rescaled, 'images/runway_accum_blurred.png');
params = findmaxima( runway_accum_blurred, runway_theta, runway_rho, thold );
runway_accum_points = drawpoints( runway_accum_blurred_rescaled, params, runway_theta, runway_rho );
imwrite(runway_accum_points, sprintf('images/runway_accum_blurred_points_%0.2f.png',thold));
runway_lines = drawlines( runway, params );
imwrite(runway_lines, sprintf('images/runway_blurred_lines_%0.2f.png',thold));
% decremented accumulator
runway_theta = [0,pi/1000,pi/2];
[runway_accum_decr,runway_rho] = hough_decrement( runway_edge , runway_theta );
runway_accum_decr_rescaled = rescaleDiffImage(runway_accum_decr);
imwrite(runway_accum_decr_rescaled, 'images/runway_accum_decr.png');
runway_rho = runway_rho
thold = .9;
params = findmaxima( runway_accum_decr, runway_theta, runway_rho, thold );
runway_accum_decr_points = drawpoints( runway_accum_decr_rescaled, params, runway_theta, runway_rho );
imwrite(runway_accum_decr_points, sprintf('images/runway_accum_decr_points_%0.1f.png',thold));
runway_lines = drawlines( runway, params );
imwrite(runway_lines, sprintf('images/runway_decr_lines_%0.1f.png',thold));
thold = .7;
params = findmaxima( runway_accum_decr, runway_theta, runway_rho, thold );
runway_accum_decr_points = drawpoints( runway_accum_decr_rescaled, params, runway_theta, runway_rho );
imwrite(runway_accum_decr_points, sprintf('images/runway_accum_decr_points_%0.1f.png',thold));
runway_lines = drawlines( runway, params );
imwrite(runway_lines, sprintf('images/runway_decr_lines_%0.1f.png',thold));

shapes_ori = orientationMap( shapes );
imwrite(rescaleDiffImage(shapes_ori), 'images/shapes_ori.png');
shapes_theta = [0,pi/1000,pi/2];
[shapes_accum_ori,shapes_rho] = hough_orientation( shapes_edge, shapes_ori , shapes_theta );
shapes_accum_ori_rescaled = rescaleDiffImage(shapes_accum_ori);
imwrite(shapes_accum_ori_rescaled, 'images/shapes_accum_ori.png');
shapes_rho = shapes_rho
thold = .9;
params = findmaxima( shapes_accum_ori, shapes_theta, shapes_rho, thold );
shapes_accum_ori_points = drawpoints( shapes_accum_ori_rescaled, params, shapes_theta, shapes_rho );
imwrite(shapes_accum_ori_points, sprintf('images/shapes_accum_ori_points_%0.1f.png',thold));
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_ori_lines_%0.1f.png',thold));
thold = .7;
params = findmaxima( shapes_accum_ori, shapes_theta, shapes_rho, thold );
shapes_accum_ori_points = drawpoints( shapes_accum_ori_rescaled, params, shapes_theta, shapes_rho );
imwrite(shapes_accum_ori_points, sprintf('images/shapes_accum_ori_points_%0.1f.png',thold));
shapes_lines = drawlines( shapes, params );
imwrite(shapes_lines, sprintf('images/shapes_ori_lines_%0.1f.png',thold));

runway_ori = orientationMap( runway );
imwrite(rescaleDiffImage(runway_ori), 'images/runway_ori.png');
runway_theta = [0,pi/1000,pi/2];
[runway_accum_ori,runway_rho] = hough_orientation( runway_edge, runway_ori , runway_theta );
runway_accum_ori_rescaled = rescaleDiffImage(runway_accum_ori);
imwrite(runway_accum_ori_rescaled, 'images/runway_accum_ori.png');
runway_rho = runway_rho
thold = .9;
params = findmaxima( runway_accum_ori, runway_theta, runway_rho, thold );
runway_accum_ori_points = drawpoints( runway_accum_ori_rescaled, params, runway_theta, runway_rho );
imwrite(runway_accum_ori_points, sprintf('images/runway_accum_ori_points_%0.1f.png',thold));
runway_lines = drawlines( runway, params );
imwrite(runway_lines, sprintf('images/runway_ori_lines_%0.1f.png',thold));
thold = .7;
params = findmaxima( runway_accum_ori, runway_theta, runway_rho, thold );
runway_accum_ori_points = drawpoints( runway_accum_ori_rescaled, params, runway_theta, runway_rho );
imwrite(runway_accum_ori_points, sprintf('images/runway_accum_ori_points_%0.1f.png',thold));
runway_lines = drawlines( runway, params );
imwrite(runway_lines, sprintf('images/runway_ori_lines_%0.1f.png',thold));



