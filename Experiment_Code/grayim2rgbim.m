function rgbimage = grayim2rgbim(im)

% rgbimage = grayim2rgbim(im)
%
% converts an [M x N x 1] grayscale image <im> to an [M x N x 3] RGB image,
% useful for then adding color.

rgbimage(:,:,1) = im;
rgbimage(:,:,2) = im;
rgbimage(:,:,3) = im;