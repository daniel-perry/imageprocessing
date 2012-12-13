all external code used for the project is kept here, along with
some explanation on why it is used.

1. imresample - a method for resampling from the matlab file exchange
(http://www.mathworks.com/matlabcentral/fileexchange/22443-image-resampling)

I only implemented linear resampling in the resampling project, 
but I wanted to upsample the images using cubic resampling.
Since resampling isn't integral to the project, I figured it
was fine to use external code, instead of writing it.


2.  kp_harris - Harris key point extraction.
(http://www.mathworks.com/matlabcentral/fileexchange/17894-keypoint-extraction)

This code implements the harris key point extraction, used to
locate the "important points" in the image, where features will
then be extracted.


