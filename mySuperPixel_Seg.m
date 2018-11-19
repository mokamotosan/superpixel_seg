function mySuperPixel_Seg(imgfile)
%% mySuperPixel_seg.m
% created by Kei. Ohtsuka@MathWorks
% modified by M. Okamoto@FMU

%% �摜�̓Ǎ��݁E�\��
I = imread(imgfile);
figure; imshow(I);

%% L*a*b*�F��Ԃւ̕ϊ�
I = im2double(I);
Ilab = rgb2lab(I);     % �ϓ��F���

%% �X�[�p�[�s�N�Z����p�����̈�ɕ���
%    �ڕW�F�����T�C�Y�́A1000�̗ގ��F�̈�ɂȂ�悤�ɕ���
[L, N] = superpixels(Ilab, 1000, 'IsInputLab',true);     % �f�t�H���g�ł͓�����L*a*b*�֕ϊ�
N                             % N :���ʓI�ɐ������ꂽ�X�[�p�[�s�N�Z����
imtool(L, []);                % Ls:���x���摜

%% �X�[�p�[�s�N�Z���̕\��
Bmask = boundarymask(L);             % ���x�����E���g���[�X�i2�l�摜�j
I1 = imoverlay(I, Bmask,'cyan');      % �摜���ɁA2�l�摜���w��F�ŏ㏑��
figure;imshow(I1); shg;

%% �X�[�p�[�s�N�Z�����ɕ��ϒl���Z�o���A���ω�
rng('default')
pixelIdxList = label2idx(L);
meanColor = zeros(N,3);
[m,n] = size(L);
for  i = 1:N
    meanColor(i,1) = mean(Ilab(pixelIdxList{i}));
    meanColor(i,2) = mean(Ilab(pixelIdxList{i}+m*n));
    meanColor(i,3) = mean(Ilab(pixelIdxList{i}+2*m*n));
end

%% K-means���g���ăN���X�^�����O
numColors = 5;
[idx,cmap] = kmeans(meanColor,numColors,'replicates',3);
cmap = lab2rgb(cmap);
Lout = zeros(size(I,1),size(I,2));
for i = 1:N
    Lout(pixelIdxList{i}) = idx(i);
end
imshow(label2rgb(Lout))

%% �֘A�̈�I��
bw = Lout == 5;
bw = imclose(bw, strel('disk',3));
imshow(bw)

%% �ג����̈�폜
bw2 = bwpropfilt(bw, 'Eccentricity', [0, 0.97]);
imshow(bw2);

%% ���W���
stats = regionprops(bw2, 'Extrema');
%left/right-bottom�𒊏o
for i = 1:size(stats,1)
    xy(i*2-1:i*2,:) = stats(i).Extrema([5,6],:);
end
I2 = insertMarker(I,xy,'circle');
figure, imshow(I2)

%% �t�B�b�e�B���O
%cftool(xy(:,1),xy(:,2));
ft = fittype( 'poly2' );
% ���f�����f�[�^�ɋߎ����܂��B
fittedmodel = fit(xy(:,1),xy(:,2),ft);

%% ���ʏ㏑��
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

