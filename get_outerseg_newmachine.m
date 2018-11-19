function [xaxis, yaxis, yaxis2, xy_outer] = get_outerseg_newmachine(imgfile)
%% mySuperPixel_seg.m
% created by Kei. Ohtsuka@MathWorks
% modified by M. Okamoto@FMU
% グレイスケール画像用

%imgfile = 'EnhancedVessel0000.bmp';

%% 画像の読込み・表示
I = imread(imgfile);
%figure; imshow(I);

%% データ型変換
I = im2double(I);

%% 両端をトリミング
Itrim = I(:, 50:450);

%% スーパーピクセルを用い小領域に分割
%    目標：同じサイズの、1000個の類似色領域になるように分割
[L, N] = superpixels(Itrim, 1000, 'IsInputLab',true);     % デフォルトでは内部でL*a*b*へ変換
N;                             % N :結果的に生成されたスーパーピクセル数
imtool(L, []);                % Ls:ラベル画像

%% スーパーピクセルの表示
Bmask = boundarymask(L);             % ラベル境界をトレース（2値画像）
I1 = imoverlay(Itrim, Bmask,'cyan');      % 画像中に、2値画像を指定色で上書き
%figure;imshow(I1); shg;

%% スーパーピクセル毎に平均値を算出し、平均化
rng('default')
pixelIdxList = label2idx(L);
meanColor = zeros(N,1);
for  i = 1:N
    meanColor(i,1) = mean(Itrim(pixelIdxList{i}));
end

%% K-meansを使ってクラスタリング
numColors = 2;
[idx,~] = kmeans(meanColor,numColors,'replicates',3);
Lout = zeros(size(Itrim,1),size(Itrim,2));
for i = 1:N
    Lout(pixelIdxList{i}) = idx(i);
end
%imshow(label2rgb(Lout))

%% 関連領域選択
bw = Lout == 2;
bw = imclose(bw, strel('disk',3));
%imshow(bw)

%% 関心領域の選択
bw2 = bwpropfilt(bw, 'Area', 100);
%imshow(bw2);

%% 座標情報
stats = regionprops(bw2, 'Extrema');
% top-left, top-rightを抽出
for i = 1:size(stats,1)
    xy(i*2-1:i*2,:) = stats(i).Extrema([1,2],:);
end
I2 = insertMarker(Itrim,xy,'circle');
%figure, imshow(I2)

%% フィッティング
%cftool(xy(:,1),xy(:,2));
ft = fittype( 'poly1' );
% モデルをデータに近似します。
fittedmodel = fit(xy(:,1),xy(:,2),ft);
% 近似曲線のデータを準備
xaxis = (1:size(I,2))';
yaxis = fittedmodel(xaxis);
% 近似曲線が最外側点を通るように補正
[~, idx] = min(xy(:,2));
xy_outer = xy(idx,:);
yaxis = yaxis + xy_outer(2) - fittedmodel(xy_outer(1));

% 水平な直線を引く
yaxis2 = ones(size(xaxis))*xy_outer(2);

%% 結果上書き
% fh = figure; imshow(Itrim);
% hold on;
% plot(xaxis, yaxis, 'r', 'LineWidth', 2);
 
%% save the result fig
% [p, f] = fileparts(imgfile);
% if isempty(p); p = '.' ; end
% savepath = [p filesep 'results'];
% if exist(savepath) ~= 7; mkdir(savepath); end
% saveas(fh, fullfile(savepath, [f '_result.tif']));

%% refresh
%clc;clear;close all;imtool close all;

% Copyright 2018 The MathWorks, Inc.