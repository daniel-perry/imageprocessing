function show_test( test_image, codebook_pos, codebook_neg, threshold, patch_radius )

progress = 'calculating coverage...'
tic
accum = hough_coverage( test_image, codebook_pos, codebook_neg, threshold, patch_radius );
duration = toc

thold = max(accum(:)) * .95

keypoints = kp_harris( test_image );
key_image = drawpoints( test_image, keypoints );

close all;
scrsz = get(0,'ScreenSize');
figure('Position', [1 scrsz(4) scrsz(3)/2 scrsz(4)]);
rows = 4;
cols = 1;
plot_i = 1;
subplot(rows,cols,plot_i)
plot_i = plot_i + 1;
imshow( test_image )
subplot(rows,cols,plot_i)
plot_i = plot_i + 1;
imshow( key_image )
subplot(rows,cols,plot_i)
plot_i = plot_i + 1;
addpath('../spatial_filtering')
imshow( rescaleDiffImage( accum ) )
subplot(rows,cols,plot_i)
plot_i = plot_i + 1;
imshow( uint8( 255* (accum > thold) ) )


