%% initiate
clear; close all; imtool close all; clc

%% select an imge dir
imgdir = uigetdir('..');

%% listing images
imglist = dir(fullfile(imgdir, '*.bmp'));

%% process
numImg = length(imglist);
for iImg = 1:numImg
    disp(iImg)
    mySuperPixel_Seg_ver3(fullfile(imglist(iImg).folder, imglist(iImg).name));
end