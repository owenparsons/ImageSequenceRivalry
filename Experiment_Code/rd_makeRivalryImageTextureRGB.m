function [imageTexture imagetexPointer] = rd_makeRivalryImageTextureRGB(window, imageFilePathLeft, imageFilePathRight, tintLeft, tintRight)

% Given two image file paths, create a color image texture with one image on the left and the other
% on the right in rivalry fashion. <tintLeft> and <tintRight> are [R G B] 1x3 arrays. 
% Tint arguments are optional, but if you give a tint for one image, be sure to give one
% for the other image, or use an [] argument.
%
% Rachel Denison
% July 2009

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pixelsPerDegree;

if isempty(pixelsPerDegree)
    pixelsPerDegree = 99; % this is with NEC Monitor with subject sitting 5 feet from the screen. 1280 x 1024 pixel fullscreen.
    display ('in present rivalry targets - passing global variable ppd did not work');
end;

global spaceBetweenMultiplier;
if isempty(spaceBetweenMultiplier)
    spaceBetweenMultiplier = 2;
    display ('error is passing global sbm in present rivalry targs...');
end;

% ---------------------------------
% User option
% ---------------------------------
equalize_histogram = 'eq'; % 'eq' for histeq, 'adapteq' for adapthisteq, 'none' for use original 

% ---------------------------------
% Deal with input
% ---------------------------------

% if there are no tints or only 1 tint given
if nargin == 3
    tintLeft = [1 1 1];
    tintRight = [1 1 1];
else
    if isempty(tintLeft)
        tintLeft = [1 1 1];
    end
    if isempty(tintRight)
        tintRight = [1 1 1];
    end
end

% ---------------------------------
% Color Setup
% ---------------------------------
% Gets color values.

% Retrieves color codes for black and white and gray.
black = BlackIndex(window);  % Retrieves the CLUT color code for black.
white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
gray = (black + white) / 2;  % Computes the CLUT color code for gray.


% ---------------------------------
% Annulus & Image Setup
% ---------------------------------

% Set diameter of targets, diameter and thickness of convergence annulus
circleDiameterDegrees = 1.8; % Diameter of presented circle in degrees of visual field.
convergenceAnnulusDiameterDegrees = 2.6; % Diameter of black annulus which individually surrounds both the target gratings
convergenceAnnulusThicknessDegrees = .2;
blurRadius = 0.1; % Proportion of circle radius that is blurred on the outer edge

circleDiameterPixels = circleDiameterDegrees * pixelsPerDegree;
convergenceAnnulusDiameterPixels = convergenceAnnulusDiameterDegrees * pixelsPerDegree;
convergenceAnnulusThicknessPixels = convergenceAnnulusThicknessDegrees* pixelsPerDegree;

widthOfGrid = convergenceAnnulusDiameterPixels ; % the next lines make sure that it is a whole, even number so matrix indices don't choke.
widthOfGrid = round (widthOfGrid);
if mod (widthOfGrid, 2) ~= 0
    widthOfGrid = widthOfGrid + 1 ;
end;

halfWidthOfGrid =  (widthOfGrid / 2);
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid; % widthArray is used in creating the meshgrid.

% Creates a two-dimensional square grid
[x y] = meshgrid(widthArray, widthArray);

% Now we create an annulus that surrounds our circular grating
convergenceAnnulus = ...
    ((x.^2 + y.^2) >= (convergenceAnnulusDiameterPixels/2 - convergenceAnnulusThicknessPixels)^2 )  & ...
    ((x.^2 + y.^2) <  (convergenceAnnulusDiameterPixels/2)^2 );

convergenceAnnulus = ~convergenceAnnulus; % when we multiply this, it will create an annulus of zero/black

% ------------------------------------------
% Make masks and masked images
% ------------------------------------------

% set up remaining building blocks
annulussize = size(convergenceAnnulus,1);
imsize = round(circleDiameterPixels);
mask = drawcircularblur(imsize, blurRadius);
square = ones(annulussize) * gray;
cornerPos = round((annulussize - imsize)/2);

% read, resize, adjust histogram, tint, and mask image 1
im1 = imread(imageFilePathLeft);
im1 = imresize(im1,[imsize imsize]);
switch equalize_histogram
    case 'eq'
        im1 = histeq(im1);
    case 'adapteq'
        im1 = adapthisteq(im1);
    otherwise
        % do nothing
end
im1Tinted = imtint(double(im1), tintLeft);
im1Masked = maskrgbim(im1Tinted, mask, [gray gray gray]);

% place image on a larger background square
square1 = repmat(square, [1 1 3]);
square1(cornerPos:cornerPos + imsize - 1, cornerPos:cornerPos + imsize - 1, 1) = im1Masked(:,:,1);
square1(cornerPos:cornerPos + imsize - 1, cornerPos:cornerPos + imsize - 1, 2) = im1Masked(:,:,2);
square1(cornerPos:cornerPos + imsize - 1, cornerPos:cornerPos + imsize - 1, 3) = im1Masked(:,:,3);

% add the convergence annulus to the background square
imageMatrix1(:,:,1) = square1(:,:,1) .* convergenceAnnulus;
imageMatrix1(:,:,2) = square1(:,:,2) .* convergenceAnnulus;
imageMatrix1(:,:,3) = square1(:,:,3) .* convergenceAnnulus;
imageMatrix1 = uint8(imageMatrix1);

% do the same steps for image 2 ...
im2 = imread(imageFilePathRight);
im2 = imresize(im2,[imsize imsize]);
switch equalize_histogram
    case 'eq'
        im2 = histeq(im2);
    case 'adapteq'
        im2 = adapthisteq(im2);
    otherwise
        % do nothing
end
im2Tinted = imtint(double(im2), tintRight);
im2Masked = maskrgbim(im2Tinted, mask, [gray gray gray]);

square2 = repmat(square, [1 1 3]);
square2(cornerPos:cornerPos + imsize - 1, cornerPos:cornerPos + imsize - 1, 1) = im2Masked(:,:,1);
square2(cornerPos:cornerPos + imsize - 1, cornerPos:cornerPos + imsize - 1, 2) = im2Masked(:,:,2);
square2(cornerPos:cornerPos + imsize - 1, cornerPos:cornerPos + imsize - 1, 3) = im2Masked(:,:,3);

imageMatrix2(:,:,1) = square2(:,:,1) .* convergenceAnnulus;
imageMatrix2(:,:,2) = square2(:,:,2) .* convergenceAnnulus;
imageMatrix2(:,:,3) = square2(:,:,3) .* convergenceAnnulus;
imageMatrix2 = uint8(imageMatrix2);


% -----------------------------------
% Make blank and spacer matrices
% -----------------------------------

% Create matrices
graySpacerMatrix =  ones(widthOfGrid+1,(widthOfGrid)*spaceBetweenMultiplier ) * gray;
blankTargetMatrix = ones(widthOfGrid+1, widthOfGrid+1) * gray;
blankedGratingMatrix = blankTargetMatrix .*convergenceAnnulus;

% Convert into RGB
graySpacerMatrixRGB = uint8(grayim2rgbim(graySpacerMatrix));
blankedGratingMatrixRGB = uint8(grayim2rgbim(blankedGratingMatrix));


% ------------------------------------
% Make textures
% ------------------------------------
imageTexture = [imageMatrix1, graySpacerMatrixRGB, imageMatrix2];
blankTexture = [blankedGratingMatrixRGB, graySpacerMatrixRGB, blankedGratingMatrixRGB];

imagetexPointer = Screen('MakeTexture', window, imageTexture);
blanktexPointer = Screen('MakeTexture', window, blankTexture);


