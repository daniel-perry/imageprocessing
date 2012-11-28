% rescales a diff image so that pixels are in the [0,255] range.
function Im = rescaleDiffImage(DiffIm)

min_value = min(DiffIm(:));
Im = DiffIm - min_value; 
% min is now zero
scale_factor = 255/max(Im(:));
Im = Im * scale_factor;
Im = uint8(Im);

