function mySuperPixel_Seg(imgfile)
%% mySuperPixel_seg.m
% created by Kei. Ohtsuka@MathWorks
% modified by M. Okamoto@FMU

%% 画像の読込み・表示
I = imread(imgfile);
figure; imshow(I);

%% L*a*b*色空間への変換
I = im2double(I);
Ilab = rgb2lab(I);     % 均等色空間

%% スーパーピクセルを用い小領域に分割
%    目標：同じサイズの、1000個の類似色領域になるように分割
[L, N] = superpixels(Ilab, 1000, 'IsInputLab',true);     % デフォルトでは内部でL*a*b*へ変換
N                             % N :結果的に生成されたスーパーピクセル数
imtool(L, []);                % Ls:ラベル画像

%% スーパーピクセルの表示
Bmask = boundarymask(L);             % ラベル境界をトレース（2値画像）
I1 = imoverlay(I, Bmask,'cyan');      % 画像中に、2値画像を指定色で上書き
figure;imshow(I1); shg;

%% スーパーピクセル毎に平均値を算出し、平均化
rng('default')
pixelIdxList = label2idx(L);
meanColor = zeros(N,3);
[m,n] = size(L);
for  i = 1:N
    meanColor(i,1) = mean(Ilab(pixelIdxList{i}));
    meanColor(i,2) = mean(Ilab(pixelIdxList{i}+m*n));
    meanColor(i,3) = mean(Ilab(pixelIdxList{i}+2*m*n));
end

%% K-meansを使ってクラスタリング
numColors = 5;
[idx,cmap] = kmeans(meanColor,numColors,'replicates',3);
cmap = lab2rgb(cmap);
Lout = zeros(size(I,1),size(I,2));
for i = 1:N
    Lout(pixelIdxList{i}) = idx(i);
end
imshow(label2rgb(Lout))

%% 関連領域選択
bw = Lout == 5;
bw = imclose(bw, strel('disk',3));
imshow(bw)

%% 細長い領域削除
bw2 = bwpropfilt(bw, 'Eccentricity', [0, 0.97]);
imshow(bw2);

%% 座標情報
stats = regionprops(bw2, 'Extrema');
%left/right-bottomを抽出
for i = 1:size(stats,1)
    xy(i*2-1:i*2,:) = stats(i).Extrema([5,6],:);
end
I2 = insertMarker(I,xy,'circle');
figure, imshow(I2)

%% フィッティング
%cftool(xy(:,1),xy(:,2));
ft = fittype( 'poly2' );
% モデルをデータに近似します。
fittedmodel = fit(xy(:,1),xy(:,2),ft);

%% 結果上書き
xaxis = 1:size(I,2);
yaxis = fittedmodel(xaxis);

figure, imshow(I)
hold on;
plot(xaxis, yaxis, 'g', 'LineWidth', 1);

%% save the result fig
[p, f] = fileparts(imgfile);
if isempty(p); p = '.' ; end
savepath = [p filesep 'results'];
if exist(savepath) ~= 7; mkdir(savepath); end
saveas(gcf, fullfile(savepath, [f '_result.tif']));

%% refresh
clc;clear;close all;imtool close all;

%% Copyright 2017 The MathWorks, Inc.

