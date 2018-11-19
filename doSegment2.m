%% initiate
clear; close all; imtool close all; clc

%% select an imge dir
imgdir = uigetdir('..');

%% listing images
imglist_original = dir(fullfile([imgdir filesep 'Original'], '*.bmp'));
imglist_vessel = dir(fullfile([imgdir filesep 'VesselEnhanced'], '*.bmp'));

%% process
numImg = length(imglist_original);
for iImg = 1:numImg
    disp(imglist_original(iImg).name)
    
    % get iner boarder
    [x_in, y_in, y_in2] = get_inerseg_newmachine(fullfile(imglist_original(iImg).folder, imglist_original(iImg).name));
    
    % get outer boarder
    [x_out, y_out, y2_out, xy_outer] = get_outerseg_newmachine(fullfile(imglist_vessel(iImg).folder, imglist_vessel(iImg).name));
    y_out = y_in - (y_in(round(xy_outer(1))) - y_out(round(xy_outer(1))));
    y2_out = y_in2 - (y_in2(round(xy_outer(1))) - y2_out(round(xy_outer(1))));
    
    % overlay the boarder on the original image
    Ioriginal = imread(fullfile(imglist_original(iImg).folder, imglist_original(iImg).name));
    fh = figure; imshow(Ioriginal); hold on;
    plot(x_out, y_out, 'r', 'LineWidth', 2);
    %plot(x_out, y2_out, 'g', 'LineWidth', 2);
    plot(x_in, y_in, 'r--', 'LineWidth', 2);
    %plot(x_in, y_in2, 'g--', 'LineWidth', 2);
    
    % save the figure
    savepath = [imgdir filesep 'Results'];
    if exist(savepath) ~= 7; mkdir(savepath); end
    saveas(fh, fullfile(savepath, sprintf('Result%04d.tif', iImg)));
    
    % refresh
    close all;imtool close all;
end