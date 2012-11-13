% main.m - generates all the images shown in the writeup

% images
checker_fn = '../images/checkboard.jpg';
checker = imread(checker_fn);
face1_fn = '../images/face1.png';
face1 = rgb2gray(imread(face1_fn));
face2_fn = '../images/face2.png';
face2 = rgb2gray(imread(face2_fn));
face3_fn = '../images/face3.png';
face3 = rgb2gray(imread(face3_fn));

% Local non-linear transforms
%{
sigma = 20
show_points(checker_fn, checker_fn, '../data/face_3');
[pts,alpha] = local_from_points('../data/face_3', sigma)
ch_local_3 = transform_local( checker, pts, alpha, sigma, 'linear' );
imwrite(ch_local_3,'../images/ch_local_3.png');
figure
imshow(ch_local_3)

sigma = 30
show_points(checker_fn, checker_fn, '../data/face_3');
[pts,alpha] = local_from_points('../data/face_3', sigma)
ch_local_3 = transform_local( checker, pts, alpha, sigma, 'linear' );
imwrite(ch_local_3,'../images/ch_local_3_30.png');
figure
imshow(ch_local_3)

sigma = 50
show_points(checker_fn, checker_fn, '../data/face_3');
[pts,alpha] = local_from_points('../data/face_3', sigma)
ch_local_3 = transform_local( checker, pts, alpha, sigma, 'linear' );
imwrite(ch_local_3,'../images/ch_local_3_50.png');
figure
imshow(ch_local_3)
%}

%{
sigma = 20
%show_points(face3_fn, face3_fn, '../data/face_7');
[pts,alpha] = local_from_points('../data/face_7', sigma)
f3_local_7 = transform_local( face3, pts, alpha, sigma, 'linear' );
imwrite(f3_local_7,'../images/f3_local_7_20.png');
%figure
%imshow(f3_local_7)

sigma = 30
%show_points(face3_fn, face3_fn, '../data/face_7');
[pts,alpha] = local_from_points('../data/face_7', sigma)
f3_local_7 = transform_local( face3, pts, alpha, sigma, 'linear' );
imwrite(f3_local_7,'../images/f3_local_7_30.png');
%figure
%imshow(f3_local_7)
%}

sigma = 40
%show_points(face3_fn, face3_fn, '../data/face_7');
[pts,alpha] = local_from_points('../data/face_7', sigma)
f3_local_7 = transform_local( face3, pts, alpha, sigma, 'linear' );
imwrite(f3_local_7,'../images/f3_local_7_50.png');
%figure
%imshow(f3_local_7)





% Affine transforms from landmarks
%{
% get_points(face1_fn, face2_fn, 3, '../data/face_3' )
show_points(face1_fn, face2_fn, '../data/face_3');
m = affine_from_points('../data/face_3')
f2_affine = transform( face2, m, 'linear', false );
imwrite(f2_affine,'../images/f2_affine.png');
figure
imshow(f2_affine)
%}

%{
% get_points(face1_fn, face2_fn, 5, '../data/face_5' )
show_points(face1_fn, face2_fn, '../data/face_5');
m5 = affine_from_points('../data/face_5')
f2_affine_m5 = transform( face2, m5, 'linear', false );
imwrite(f2_affine_m5,'../images/f2_affine_m5.png');
figure
imshow(f2_affine_m5)
%}

% Affine Image Transformations
%{
f1_trans_nearest = transform( face1, makeTranslate(50,50), 'nearest', true);
imwrite(f1_trans_nearest, '../images/f1_trans_nearest.png');
f1_trans_linear = transform( face1, makeTranslate(50,50), 'linear', true);
imwrite(f1_trans_linear, '../images/f1_trans_linear.png');
f1_rot_nearest = transform( face1, makeRotate(45), 'nearest', true);
imwrite(f1_rot_nearest, '../images/f1_rot_nearest.png');
f1_rot_linear = transform( face1, makeRotate(45), 'linear', true);
imwrite(f1_rot_linear, '../images/f1_rot_linear.png');

f1_rot_nearest = transform( face1, makeRotate(45), 'nearest', false);
imwrite(f1_rot_nearest, '../images/f1_rot_nearest_full.png');
f1_rot_nearest_zoomed = transform( f1_rot_nearest, makeTranslate(-10,-200)*makeScale(3,3), 'nearest', true);
imwrite(f1_rot_nearest_zoomed, '../images/f1_rot_nearest_zoomed.png');
f1_rot_linear = transform( face1, makeRotate(45), 'linear', false);
imwrite(f1_rot_linear, '../images/f1_rot_linear_full.png');
% note: we zoom with nearest neighbor on purpose...
f1_rot_linear_zoomed = transform( f1_rot_linear, makeTranslate(-10,-200)*makeScale(3,3), 'nearest', true);
imwrite(f1_rot_linear_zoomed, '../images/f1_rot_linear_zoomed.png');
%}

%{
f1_scale_nearest = transform( face1, makeScale(0.5,0.5), 'nearest', true);
imwrite(f1_scale_nearest, '../images/f1_scale_nearest.png');
f1_scale_linear = transform( face1, makeScale(0.5,0.5), 'linear', true);
imwrite(f1_scale_linear, '../images/f1_scale_linear.png');

f1_shear_nearest = transform( face1, makeShear(0,0.5), 'nearest', false);
imwrite(f1_shear_nearest, '../images/f1_shear_nearest.png');
f1_shear_linear = transform( face1, makeShear(0,0.5), 'linear', false);
imwrite(f1_shear_linear, '../images/f1_shear_linear.png');
%}

%{
imsize = size(face1);
all = makeTranslate(-imsize(1)/2,-imsize(2)/2)*makeRotate(70)*makeShear(0.5,0)*makeTranslate(imsize(1)/3,imsize(2)/3)
f1_all_nearest = transform( face1, all, 'nearest', false);
imwrite(f1_all_nearest, '../images/f1_all_nearest.png');
f1_all_linear = transform( face1, all, 'linear', false);
imwrite(f1_all_linear, '../images/f1_all_linear.png');
%}



