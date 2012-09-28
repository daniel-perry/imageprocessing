% main - creates all the plots

%% data

crowd = imread('images/crowd.tif');
university = imread('images/university.tif');
chang = imread('images/chang.tif');
portal = imread('images/portal.tif');

checker1 = imread('images/checker1.gif');
checker2 = imread('images/checker2.gif');
ctscan = imread('images/CTscan.tif');

napali = imread('images/napali.png');
arch = imread('images/arch.png');
santiago = imread('images/santiago.png');

%% histogram
%{
sprintf('calculating histograms');
crowd_h = histogram(crowd, max(crowd(:))+1, 0, max(crowd(:)) );
checker1_h = histogram(checker1, max(checker1(:))+1, 0, max(checker1(:)) );
napali_h = histogram(napali, max(napali(:))+1, 0, max(napali(:)) );
santiago_h = histogram(santiago, max(santiago(:))+1, 0, max(santiago(:)) );

bar(crowd_h);
title('histogram of crowd image');
xlabel('intensity');
ylabel('frequency');

input('press any key to continue...');

bar(checker1_h);
title('histogram of checker1 image');
xlabel('intensity');
ylabel('frequency');

input('press any key to continue...');

bar(napali_h);
title('histogram of napali image');
xlabel('intensity');
ylabel('frequency');

input('press any key to continue...');

bar(santiago_h);
title('histogram of santiago image');
xlabel('intensity');
ylabel('frequency');

input('press any key to continue...');
%}

%% histogram equalization
%{
sprintf('histogram equalizing images...');
crowd_eq = histoeq(crowd, max(crowd(:))+1, 0, max(crowd(:)) );
crowd_eq_h = histogram(crowd_eq, max(crowd_eq(:))+1, 0, max(crowd_eq(:))+1);
university_eq = histoeq(university, max(university(:))+1, 0, max(university(:)) );
university_eq_h = histogram(university_eq, max(university_eq(:))+1, 0, max(university_eq(:))+1);
chang_eq = histoeq(chang, max(chang(:))+1, 0, max(chang(:)) );
chang_eq_h = histogram(chang_eq, max(chang_eq(:))+1, 0, max(chang_eq(:))+1);
portal_eq = histoeq(portal, max(portal(:))+1, 0, max(portal(:)) );
portal_eq_h = histogram(portal_eq, max(portal_eq(:))+1, 0, max(portal_eq(:))+1);
napali_eq = histoeq(napali, max(napali(:))+1, 0, max(napali(:)) );
napali_eq_h = histogram(napali_eq, max(napali_eq(:))+1, 0, max(napali_eq(:))+1);
santiago_eq = histoeq(santiago, max(santiago(:))+1, 0, max(santiago(:)) );
santiago_eq_h = histogram(santiago_eq, max(santiago_eq(:))+1, 0, max(santiago_eq(:))+1);
arch_eq = histoeq(arch, max(arch(:))+1, 0, max(arch(:)) );
arch_eq_h = histogram(arch_eq, max(arch_eq(:))+1, 0, max(arch_eq(:))+1);
arch_h = histogram(arch, max(arch(:))+1, 0, max(arch(:))+1);

imwrite(crowd_eq, 'images/crowd_eq.png');
imwrite(university_eq, 'images/university_eq.png');
imwrite(chang_eq, 'images/chang_eq.png');
imwrite(portal_eq, 'images/portal_eq.png');
imwrite(napali_eq, 'images/napali_eq.png');
imwrite(santiago_eq, 'images/santiago_eq.png');
imwrite(arch_eq, 'images/arch_eq.png');

bar(crowd_eq_h);
title('histogram of histogram equalized crowd image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

bar(university_eq_h);
title('histogram of histogram equalized university image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

bar(chang_eq_h);
title('histogram of histogram equalized chang image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

bar(portal_eq_h);
title('histogram of histogram equalized portal image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

bar(napali_eq_h);
title('histogram of histogram equalized napali image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

bar(santiago_eq_h);
title('histogram of histogram equalized santiago image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

bar(arch_eq_h);
title('histogram of histogram equalized arch image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

bar(arch_h);
title('histogram of arch image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

chang_h = histogram(chang, max(chang(:))+1, 0, max(chang(:))+1);
bar(chang_h);
title('histogram of chang image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

university_h = histogram(university, max(university(:))+1, 0, max(university(:))+1);
bar(university_h);
title('histogram of university image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

portal_h = histogram(portal, max(portal(:))+1, 0, max(portal(:))+1);
bar(portal_h);
title('histogram of portal image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

%  blended histoeq => histoeq2

% couldn't tell the difference?
portal_alpha_eq1 = histoeq2(portal, max(portal(:))+1, 0, max(portal(:)), .5 );
imwrite(portal_alpha_eq1, 'images/portal_alpha_eq1.png');
portal_alpha_eq1_h = histogram(portal_alpha_eq1, max(portal_alpha_eq1(:))+1, 0, max(portal_alpha_eq1(:)) );
bar(portal_alpha_eq1_h);
title('histogram of equalized portal image blended at 0.5');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

portal_alpha_eq2 = histoeq2(portal, max(portal(:))+1, 0, max(portal(:)), .9 );
imwrite(portal_alpha_eq2, 'images/portal_alpha_eq2.png');
portal_alpha_eq2_h = histogram(portal_alpha_eq2, max(portal_alpha_eq2(:))+1, 0, max(portal_alpha_eq2(:)) );
bar(portal_alpha_eq2_h);
title('histogram of equalized portal image blended at 0.9');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

portal_alpha_eq3 = histoeq2(portal, max(portal(:))+1, 0, max(portal(:)), .2 );
imwrite(portal_alpha_eq3, 'images/portal_alpha_eq3.png');
portal_alpha_eq3_h = histogram(portal_alpha_eq3, max(portal_alpha_eq3(:))+1, 0, max(portal_alpha_eq3(:)) );
bar(portal_alpha_eq3_h);
title('histogram of equalized portal image blended at 0.2');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');



% napali_alpha_eq3 was the best!
napali_alpha_eq1 = histoeq2(napali, max(napali(:))+1, 0, max(napali(:)), .5 );
imwrite(napali_alpha_eq1, 'images/napali_alpha_eq1.png');
napali_alpha_eq1_h = histogram(napali_alpha_eq1, max(napali_alpha_eq1(:))+1, 0, max(napali_alpha_eq1(:)) );
bar(napali_alpha_eq1_h);
title('histogram of equalized napali image blended at 0.2');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

napali_alpha_eq2 = histoeq2(napali, max(napali(:))+1, 0, max(napali(:)), .9 );
imwrite(napali_alpha_eq2, 'images/napali_alpha_eq2.png');
napali_alpha_eq2_h = histogram(napali_alpha_eq2, max(napali_alpha_eq2(:))+1, 0, max(napali_alpha_eq2(:)) );
bar(napali_alpha_eq2_h);
title('histogram of equalized napali image blended at 0.2');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

napali_alpha_eq3 = histoeq2(napali, max(napali(:))+1, 0, max(napali(:)), .2 );
imwrite(napali_alpha_eq3, 'images/napali_alpha_eq3.png');
napali_alpha_eq3_h = histogram(napali_alpha_eq3, max(napali_alpha_eq3(:))+1, 0, max(napali_alpha_eq3(:)) );
bar(napali_alpha_eq3_h);
title('histogram of equalized napali image blended at 0.2');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

%}

%% Segmentation
% histograms:

%{
checker1_h = histogram(checker1, max(checker1(:))+1, 0, max(checker1(:)) );
checker2_h = histogram(checker2, max(checker2(:))+1, 0, max(checker2(:)) );
ctscan_h = histogram(ctscan, 100, 0, max(ctscan(:)) );

% checker1: visually valley is at 110
bar(checker1_h);
title('histogram of checker1 image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

% checker2: visually valley is at 103
bar(checker2_h);
title('histogram of checker2 image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

ctscan_h = histogram(ctscan, max(ctscan(:))+1, 0, max(ctscan(:)) );
% ctscan: visually valley is at 200 and 50
bar(ctscan_h);
title('histogram of ctscan image');
xlabel('intensity');
ylabel('frequency');
input('press any key to continue');

% threshold them:
checker1_manual_th = checker1 >= 110;
imwrite(checker1_manual_th, 'images/checker1_manual_th.png');

checker2_manual_th = checker2 >= 103;
imwrite(checker2_manual_th, 'images/checker2_manual_th.png');

ctscan_manual_th1 = ctscan >= 200;
imwrite(ctscan_manual_th1, 'images/ctscan_manual_th_1.png');
ctscan_manual_th2 = (ctscan < 200) .* (ctscan>=50);
imwrite(ctscan_manual_th2, 'images/ctscan_manual_th_2.png');
%}

%{

%checker1 simple model:
checker1_dark = double(checker1(138:255,1:118));
checker1_dark_mean = mean(checker1_dark(:))
checker1_dark_std = std(checker1_dark(:))
checker1_light = double(checker1(1:118,1:118));
checker1_light_mean = mean(checker1_light(:))
checker1_light_std = std(checker1_light(:))
%checker1_dark_mean =
% 76.3367
%checker1_dark_std =
% 20.1549
%checker1_light_mean =
%  140.5080
%checker1_light_std =
%  20.0033

% checker1 em-gmm:
%[ch1_means,ch1_var,ch1_mix] = emgmm( checker1, 2, 100)

checker1_h = histogram(checker1, max(checker1(:))+1, 0, max(checker1(:)) );
xaxis = double(0:max(checker1(:)));
means = checker1_dark_mean*ones(size(xaxis));
sds = checker1_dark_std*ones(size(xaxis));
checker1_dark_gauss = normalpdf( xaxis, means, sds );

means = checker1_light_mean*ones(size(xaxis));
sds = checker1_light_std*ones(size(xaxis));
checker1_light_gauss = normalpdf( xaxis, means, sds );

% estimate valley by finding center of means:
checker1_simplemodel_th_val = (checker1_light_mean+checker1_dark_mean)/2;
checker1_simplemodel_th = checker1 >= checker1_simplemodel_th_val;
imwrite(checker1_simplemodel_th, 'images/checker1_simplemodel_th.png');

bar(checker1_h);
hold;
title('histogram of checker1 image with gaussian model overlaid');
xlabel('intensity');
ylabel('frequency');
p1 = plot(xaxis,checker1_dark_gauss);
set(p1,'Color','red','LineWidth',2);
p2 = plot(xaxis,checker1_light_gauss);
set(p2,'Color','green','LineWidth',2);
hold;
input('press any key to continue');



%checker2 simple model:
checker2_light = double(imread('images/checker2_light.png'));
checker2_light_mean = mean(checker2_light(:))
checker2_light_std = std(checker2_light(:))
checker2_dark = double(imread('images/checker2_dark.png'));
checker2_dark_mean = mean(checker2_dark(:))
checker2_dark_std = std(checker2_dark(:))
%checker2_light_mean =
%  138.6601
%checker2_light_std =
%   19.6916
%checker2_dark_mean =
%   74.4844
%checker2_dark_std =
%   19.4231

checker2_h = histogram(checker2, max(checker2(:))+1, 0, max(checker2(:)) );
xaxis = double(0:max(checker2(:)));
means = checker2_dark_mean*ones(size(xaxis));
sds = checker2_dark_std*ones(size(xaxis));
checker2_dark_gauss = normalpdf( xaxis, means, sds );

means = checker2_light_mean*ones(size(xaxis));
sds = checker2_light_std*ones(size(xaxis));
checker2_light_gauss = normalpdf( xaxis, means, sds );

% estimate valley by finding center of means:
checker2_simplemodel_th_val = (checker2_light_mean+checker2_dark_mean)/2;
checker2_simplemodel_th = checker2 >= checker2_simplemodel_th_val;
imwrite(checker2_simplemodel_th, 'images/checker2_simplemodel_th.png');


bar(checker2_h);
hold;
title('histogram of checker2 image with guassian model overlaid');
xlabel('intensity');
ylabel('frequency');
p1 = plot(xaxis,checker2_dark_gauss);
set(p1,'Color','red','LineWidth',2);
p2 = plot(xaxis,checker2_light_gauss);
set(p2,'Color','green','LineWidth',2);
hold;
input('press any key to continue');

%}


%ctscan simple model:
ctscan_bone = double(imread('images/ct_bone.png'));
ctscan_bone_mean = mean(ctscan_bone(:))
ctscan_bone_std = std(ctscan_bone(:))
ctscan_tissue = double(imread('images/ct_tissue.png'));
ctscan_tissue_mean = mean(ctscan_tissue(:))
ctscan_tissue_std = std(ctscan_tissue(:))
%ctscan_bone_mean =
%  253.7172
%ctscan_bone_std =
%    2.1526
%ctscan_tissue_mean =
%  118.1591
%ctscan_tissue_std =
%   12.3770

ctscan_h = histogram(ctscan, max(ctscan(:))+1, 0, max(ctscan(:)) );
xaxis = double(0:max(ctscan(:)));
means = ctscan_tissue_mean*ones(size(xaxis));
sds = ctscan_tissue_std*ones(size(xaxis));
ctscan_tissue_gauss = normalpdf( xaxis, means, sds );

means = ctscan_bone_mean*ones(size(xaxis));
sds = ctscan_bone_std*ones(size(xaxis));
ctscan_bone_gauss = normalpdf( xaxis, means, sds );

% estimate valley by finding center of means:
ctscan_simplemodel_bone_th_val = (ctscan_bone_mean+ctscan_tissue_mean)/2
ctscan_simplemodel_bone_th = ctscan >= ctscan_simplemodel_bone_th_val;
imwrite(ctscan_simplemodel_bone_th, 'images/ctscan_simplemodel_bone_th.png');

ctscan_simplemodel_tissue_th_val = (ctscan_tissue_mean+0)/2
ctscan_simplemodel_tissue_th = (ctscan >= ctscan_simplemodel_tissue_th_val) .* (ctscan < ctscan_simplemodel_bone_th_val);
imwrite(ctscan_simplemodel_tissue_th, 'images/ctscan_simplemodel_tissue_th.png');


bar(ctscan_h);
hold;
title('histogram of ctscan image with guassian model overlaid');
xlabel('intensity');
ylabel('frequency');
p1 = plot(xaxis,ctscan_tissue_gauss);
set(p1,'Color','red','LineWidth',2);
p2 = plot(xaxis,ctscan_bone_gauss);
set(p2,'Color','green','LineWidth',2);
hold;
input('press any key to continue');




