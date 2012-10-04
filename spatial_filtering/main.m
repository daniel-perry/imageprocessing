% Daniel Perry
% spatial filtering and template matching examples

% image data:
% filtering and edges:
capitol = imread('images/capitol.jpg');
hand = imread('images/hand-bw.jpg');
hand = hand(:,:,1); 
%Template matching:
shapes = imread('images/shapes-bw.jpg');
shapes = shapes(:,:,1);
diamond_shape = imread('images/diamond_shape.jpg');
diamond_shape = diamond_shape(:,:,1);
weird_shape = imread('images/weird_shape.jpg');
weird_shape = weird_shape(:,:,1);
keys = imread('images/keys-bw.jpg');
keys = keys(:,:,1);
key_shape = imread('images/single_key.jpg');
key_shape = key_shape(:,:,1);
cars = imread('images/cars-bw.jpg');
cars = cars(:,:,1);
car_shape = imread('images/single_car.jpg');
car_shape = car_shape(:,:,1);
textual = imread('images/text.png');
textual = textual(:,:,1);
a_shape = imread('images/a_shape.png');
a_shape = a_shape(:,:,1);
e_shape = imread('images/e_shape.png');
e_shape = e_shape(:,:,1);
%other
napali = imread('images/napali.png');
arch = imread('images/arch.png');
santiago = imread('images/santiago.png');

%
% Image smoothing
%
% 2D box filter
%{
capitol_box3 = convolve(capitol, makeBox2D(3));
imwrite(capitol_box3,'images/capitol_box3.jpg');
capitol_box5 = convolve(capitol, makeBox2D(5));
imwrite(capitol_box5,'images/capitol_box5.jpg');
subplot(2,2,1);
imshow(capitol);
subplot(2,2,2);
imshow(capitol_box3);
subplot(2,2,3);
imshow(capitol_box5);

hand_box3 = convolve(hand, makeBox2D(3));
imwrite(hand_box3,'images/hand_box3.jpg');
hand_box5 = convolve(hand, makeBox2D(5));
imwrite(hand_box5,'images/hand_box5.jpg');
subplot(2,2,1);
imshow(hand);
subplot(2,2,2);
imshow(hand_box3);
subplot(2,2,3);
imshow(hand_box5);

napali_box3 = convolve(napali, makeBox2D(3));
imwrite(napali_box3,'images/napali_box3.jpg');
napali_box5 = convolve(napali, makeBox2D(5));
imwrite(napali_box5,'images/napali_box5.jpg');
subplot(2,2,1);
imshow(napali);
subplot(2,2,2);
imshow(napali_box3);
subplot(2,2,3);
imshow(napali_box5);

% 1D separable box

capitol_box5_1d = convolve(capitol, makeBox1D(5));
imwrite(capitol_box5_1d,'images/capitol_box5_1d.jpg');
subplot(1,2,1);
imshow(capitol);
subplot(1,2,2);
imshow(capitol_box5_1d);

hand_box5_1d = convolve(hand, makeBox1D(5));
imwrite(hand_box5_1d,'images/hand_box5_1d.jpg');
subplot(1,2,1);
imshow(hand);
subplot(1,2,2);
imshow(hand_box5_1d);

napali_box5_1d = convolve(napali, makeBox1D(5));
imwrite(napali_box5_1d,'images/napali_box5_1d.jpg');
subplot(1,2,1);
imshow(napali);
subplot(1,2,2);
imshow(napali_box5_1d);

% 1D separable gaussian

capitol_gauss1_1d = convolve(capitol, makeGauss1D(1));
imwrite(capitol_gauss1_1d,'images/capitol_gauss1_1d.jpg');
capitol_gauss3_1d = convolve(capitol, makeGauss1D(3));
imwrite(capitol_gauss3_1d,'images/capitol_gauss3_1d.jpg');
subplot(2,2,1);
imshow(capitol);
subplot(2,2,2);
imshow(capitol_gauss1_1d);
subplot(2,2,3);
imshow(capitol_gauss3_1d);

hand_gauss1_1d = convolve(hand, makeGauss1D(1));
imwrite(hand_gauss1_1d,'images/hand_gauss1_1d.jpg');
hand_gauss3_1d = convolve(hand, makeGauss1D(3));
imwrite(hand_gauss3_1d,'images/hand_gauss3_1d.jpg');
subplot(2,2,1);
imshow(hand);
subplot(2,2,2);
imshow(hand_gauss1_1d);
subplot(2,2,3);
imshow(hand_gauss3_1d);

napali_gauss1_1d = convolve(napali, makeGauss1D(1));
imwrite(napali_gauss1_1d,'images/napali_gauss1_1d.jpg');
napali_gauss3_1d = convolve(napali, makeGauss1D(3));
imwrite(napali_gauss3_1d,'images/napali_gauss3_1d.jpg');
subplot(2,2,1);
imshow(napali);
subplot(2,2,2);
imshow(napali_gauss1_1d);
subplot(2,2,3);
imshow(napali_gauss3_1d);


% 1d edge filters
capitol_x = rescaleDiffImage(convolve1D(capitol, makeDiff1D()));
imwrite(capitol_x,'images/capitol_x.jpg');
capitol_y = rescaleDiffImage(convolve1D(capitol, makeDiff1D()'));
imwrite(capitol_y,'images/capitol_y.jpg');
capitol_edge = rescaleDiffImage(edgeMap(capitol));
imwrite(capitol_edge,'images/capitol_edge.jpg');
capitol_orient = rescaleDiffImage(orientationMap(capitol));
imwrite(capitol_orient,'images/capitol_orient.jpg');
subplot(2,3,1);
imshow(capitol);
subplot(2,3,2);
imshow(capitol_x);
subplot(2,3,3);
imshow(capitol_y);
subplot(2,3,4);
imshow(capitol_edge);
subplot(2,3,5);
imshow(capitol_orient);


hand_x = rescaleDiffImage(convolve1D(hand, makeDiff1D()));
imwrite(hand_x,'images/hand_x.jpg');
hand_y = rescaleDiffImage(convolve1D(hand, makeDiff1D()'));
imwrite(hand_y,'images/hand_y.jpg');
hand_edge = rescaleDiffImage(edgeMap(hand));
imwrite(hand_edge,'images/hand_edge.jpg');
hand_orient = rescaleDiffImage(orientationMap(hand));
imwrite(hand_orient,'images/hand_orient.jpg');
subplot(2,3,1);
imshow(hand);
subplot(2,3,2);
imshow(hand_x);
subplot(2,3,3);
imshow(hand_y);
subplot(2,3,4);
imshow(hand_edge);
subplot(2,3,5);
imshow(hand_orient);

arch_x = rescaleDiffImage(convolve1D(arch, makeDiff1D()));
imwrite(arch_x,'images/arch_x.jpg');
arch_y = rescaleDiffImage(convolve1D(arch, makeDiff1D()'));
imwrite(arch_y,'images/arch_y.jpg');
arch_edge = rescaleDiffImage(edgeMap(arch));
imwrite(arch_edge,'images/arch_edge.jpg');
arch_orient = rescaleDiffImage(orientationMap(arch));
imwrite(arch_orient,'images/arch_orient.jpg');
subplot(2,3,1);
imshow(arch);
subplot(2,3,2);
imshow(arch_x);
subplot(2,3,3);
imshow(arch_y);
subplot(2,3,4);
imshow(arch_edge);
subplot(2,3,5);
imshow(arch_orient);

% 1d edge filters after guassian smoothing

capitol_gauss3 = convolve(capitol, makeGauss1D(3));
capitol_gauss3_x = rescaleDiffImage(convolve1D(capitol_gauss3, makeDiff1D()));
imwrite(capitol_gauss3_x,'images/capitol_gauss3_x.jpg');
capitol_gauss3_y = rescaleDiffImage(convolve1D(capitol_gauss3, makeDiff1D()'));
imwrite(capitol_gauss3_y,'images/capitol_gauss3_y.jpg');
capitol_gauss3_edge = rescaleDiffImage(edgeMap(capitol_gauss3));
imwrite(capitol_gauss3_edge,'images/capitol_gauss3_edge.jpg');
capitol_gauss3_orient = rescaleDiffImage(orientationMap(capitol_gauss3));
imwrite(capitol_gauss3_orient,'images/capitol_gauss3_orient.jpg');
subplot(2,3,1);
imshow(capitol_gauss3);
subplot(2,3,2);
imshow(capitol_gauss3_x);
subplot(2,3,3);
imshow(capitol_gauss3_y);
subplot(2,3,4);
imshow(capitol_gauss3_edge);
subplot(2,3,5);
imshow(capitol_gauss3_orient);

capitol_guass5 = convolve(capitol, makeGauss1D(5));
capitol_guass5_x = rescaleDiffImage(convolve1D(capitol_guass5, makeDiff1D()));
imwrite(capitol_guass5_x,'images/capitol_guass5_x.jpg');
capitol_guass5_y = rescaleDiffImage(convolve1D(capitol_guass5, makeDiff1D()'));
imwrite(capitol_guass5_y,'images/capitol_guass5_y.jpg');
capitol_guass5_edge = rescaleDiffImage(edgeMap(capitol_guass5));
imwrite(capitol_guass5_edge,'images/capitol_guass5_edge.jpg');
capitol_guass5_orient = rescaleDiffImage(orientationMap(capitol_guass5));
imwrite(capitol_guass5_orient,'images/capitol_guass5_orient.jpg');
subplot(2,3,1);
imshow(capitol_guass5);
subplot(2,3,2);
imshow(capitol_guass5_x);
subplot(2,3,3);
imshow(capitol_guass5_y);
subplot(2,3,4);
imshow(capitol_guass5_edge);
subplot(2,3,5);
imshow(capitol_guass5_orient);
%}

%{


% template matching:

% shape images

diamond_st = makeStencil(diamond_shape);
diamond_shape_match = correlate(shapes, diamond_st);
imwrite(rescaleDiffImage(diamond_shape_match), 'images/diamond_shape_match.jpg');
subplot(1,3,1)
hist(match(:),100)
diamond_shape_match_th = diamond_shape_match >= 1.18e004;
imwrite(diamond_shape_match_th, 'images/diamond_shape_match_th.jpg');
subplot(1,3,2)
imshow(diamond_shape_match_th)
subplot(1,3,3)
imshow(shapes)

weird_st = makeStencil(weird_shape);
weird_shape_match = correlate(shapes, weird_st);
imwrite(rescaleDiffImage(weird_shape_match), 'images/weird_shape_match.jpg');
subplot(1,3,1)
hist(match(:),100)
weird_shape_match_th = weird_shape_match >= 1.18e004;
imwrite(weird_shape_match_th, 'images/weird_shape_match_th.jpg');
subplot(1,3,2)
imshow(weird_shape_match_th)
subplot(1,3,3)
imshow(shapes)


% text images

e_st = makeStencil(e_shape);
n = sum(sum(e_st(e_st>0)));
e_st ./ n;
tmp = uint8( 255*ones(size(textual)));
text_tmp = tmp-textual;
% have to invert text data to make this work
e_shape_match = correlate(text_tmp, e_st);
imwrite(rescaleDiffImage(e_shape_match), 'images/e_shape_match.jpg');
subplot(1,3,1)
hist(match(:),100)
e_shape_match_th = e_shape_match >= 950;
imwrite(e_shape_match_th, 'images/e_shape_match_th.jpg');
subplot(1,3,2)
imshow(e_shape_match_th)
subplot(1,3,3)
imshow(textual)


a_st = makeStencil(a_shape);
n = sum(sum(a_st(a_st>0)));
a_st ./ n;
tmp = uint8( 255*ones(size(textual)));
text_tmp = tmp-textual;
% have to invert text data to make this work
a_shape_match = correlate(text_tmp, a_st);
imwrite(rescaleDiffImage(a_shape_match), 'images/a_shape_match.jpg');
subplot(1,3,1)
hist(match(:),100)
a_shape_match_th = a_shape_match >= 1.14e03;
imwrite(a_shape_match_th, 'images/a_shape_match_th.jpg');
subplot(1,3,2)
imshow(a_shape_match_th)
subplot(1,3,3)
imshow(textual)


%}


