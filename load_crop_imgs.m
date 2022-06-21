clear; close all;   % clear variables and close windows
AssertOpenGL;       % make sure we have OpenGL which we need for displaying 
                    % stimuli; most computers come with it now
KbName('UnifyKeyNames'); % Ensure PTB recognizes keys on all OSs
Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests, so we're not 
% forced out if the test fails
rng shuffle; % shuffle the random number generator seed

try
d = dir('random_images/*.jpg');
numImages = size(d,1); %# of images
imgs = cell(numImages, 1); %create empty array of appropriate size to hold images
croppedImgs = cell(numImages, 1);

for i=1:numImages %read contents into array
    imgs{i} = double(imread(['random_images/' d(i).name]));
end

mkdir('edited_images');
addpath('edited_images');

stdDimensions = [500, 500]; %standard size for images

for i=1:numImages
    img = imgs{i}; %access each img
    imgSize = size(img); %size of each img
    imgHeight = imgSize(1);
    imgWidth = imgSize(2);
    
    [V,I] = mink(imgSize(:,1:2),1); %find smallest elements in array and returns values and indices
    difference = V - stdDimensions(I); %difference between standard size and img size
    resize = 1 - (difference/V);
    scaledIm = imresize(img,resize); %returns rescaled img
    
    %Cropping
    scaledImageSize = size(scaledIm);
    scaledImHeight = scaledImageSize(1);
    scaledImWidth = scaledImageSize(2);
    [V,I] = maxk(scaledImageSize,1); %return max size and index
    difference = V - stdDimensions(I); 
    dCrop = difference/2; %use to crop sides equally
    
    imRect = [0 0 scaledImWidth scaledImHeight];
    if I == 1 % if height is larger dimension
       imRect(2) = dCrop;
       imRect(4) = scaledImHeight-(dCrop*2); 
    elseif I == 2 % if width is larger dimension
       imRect(1) = dCrop;
       imRect(3) = scaledImWidth-(dCrop*2); 
    end
    
    croppedImg = imcrop(scaledIm,imRect);
    croppedImgs{i} = croppedImg;
    
    %Save images
    savename = ['edited_images/edited_' d(i).name];
    imwrite(uint8(croppedImg), savename);
    
end

sca;

catch
    sca;
    psychrethrow(psychlasterror);
end