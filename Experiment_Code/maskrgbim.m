function immasked = maskrgbim(im, mask, backgroundcol)

% immasked = MASKRGBIM(im, mask, backgroundcol)
%
% Given an MxNx3 RGB image <im>, an MxNx1 grayscale mask <mask>, and a 1X3 
% RGB background color <backgroundcol>, place the mask (in background 
% color) over the RGB image. Mask values close to 1 will be replaced by the 
% background color; mask values close to zero will be replaced by the 
% image. Output the masked RGB image, <immasked>, as a uint8 array.

% mask is a double, so im should be a double for the following
% multiplication
im = double(im);

immasked(:,:,1) = im(:,:,1) .* (1-mask) + backgroundcol(1) * mask;
immasked(:,:,2) = im(:,:,2) .* (1-mask) + backgroundcol(2) * mask;
immasked(:,:,3) = im(:,:,3) .* (1-mask) + backgroundcol(3) * mask;

% color images like imtinted may need to be in uint8 to be displayed
% properly
immasked = uint8(immasked);