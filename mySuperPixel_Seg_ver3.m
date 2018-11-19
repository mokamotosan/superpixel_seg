function mySuperPixel_Seg_ver3(imgfile)
%% mySuperPixel_seg.m
% created by Kei. Ohtsuka@MathWorks
% modified by M. Okamoto@FMU

%imgfile = 'medimg.bmp';

%% �摜�̓Ǎ��݁E�\��
I = imread(imgfile);
figure; imshow(I);

%% L*a*b*�F��Ԃւ̕ϊ�
% I = im2double(I);
% Ilab = rgb2lab(I);     % �ϓ��F���
Ilab = im2double(I);

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
%meanColor = zeros(N,3);
meanColor = zeros(N,1);
[m,n] = size(L);
for  i = 1:N
    meanColor(i,1) = mean(Ilab(pixelIdxList{i}));
%     meanColor(i,2) = mean(Ilab(pixelIdxList{i}+m*n));
%     meanColor(i,3) = mean(Ilab(pixelIdxList{i}+2*m*n));
end

%% K-means���g���ăN���X�^�����O
numColors = 2;
[idx,cmap] = kmeans(meanColor,numColors,'replicates',3);
%cmap = lab2rgb(cmap);
Lout = zeros(size(I,1),size(I,2));
for i = 1:N
    Lout(pixelIdxList{i}) = idx(i);
end
imshow(label2rgb(Lout))

%% �֘A�̈�I��
bw = Lout == 2;
bw = imclose(bw, strel('disk',3));
imshow(bw)

%% �ő�ʐϗ̈�̑I���F�A�E�^�[�{�[�_�[�̌��o
bw2 = bwpropfilt(bw, 'Area', 1);
%bw2 = bwpropfilt(bw, 'Eccentricity', [0, 0.97]);
imshow(bw2);

%% ���W���
stats = regionprops(bw2, 'Extrema');
% %left/right-bottom�𒊏o
% for i = 1:size(stats,1)
%     xy(i*2-1:i*2,:) = stats(i).Extrema([5,6],:);
% end
% left-top, top-left, top-right, right-top�𒊏o
xy = stats.Extrema([8, 1, 2, 3], :);
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

fh = figure, imshow(I);
hold on;
plot(xaxis, yaxis, 'r', 'LineWidth', 2);

%% �ʐςQ�ʗ̈�̒��o�F�C���i�[�{�[�_�[�̌��o
bw3 = bwpropfilt(bw, 'Area', 4);
bw3 = xor(bw2, bw3);
figure, imshow(bw3);

%% ���W���
stats2 = regionprops(bw3, 'Extrema');
% left-top, top-left, top-right, right-top�𒊏o
for i = 1:size(stats2,1)
    xy2(i*4-3:i*4,:) = stats2(i).Extrema([8, 1, 2, 3],:);
end
%xy2 = stats2.Extrema([8, 1, 2, 3], :);
I3 = insertMarker(I,xy2,'circle');
figure, imshow(I3)


%% �t�B�b�e�B���O
%cftool(xy(:,1),xy(:,2));
ft = fittype( 'poly1' );
% ���f�����f�[�^�ɋߎ����܂��B
fittedmodel = fit(xy2(:,1),xy2(:,2),ft);

% %% �t�B�b�e�B���O
% %cftool(xy(:,1),xy(:,2));
% ft = fittype( 'poly2' );
% % ���f�����f�[�^�ɋߎ����܂��B
% fittedmodel = fit(c,r,ft);

%% ���ʏ㏑��
figure(fh), hold on;
xaxis = 1:size(I,2);
yaxis = fittedmodel(xaxis);
plot(xaxis, yaxis, 'g', 'LineWidth', 2);

%% save the result fig
[p, f] = fileparts(imgfile);
if isempty(p); p = '.' ; end
savepath = [p filesep 'results'];
if exist(savepath) ~= 7; mkdir(savepath); end
saveas(fh, fullfile(savepath, [f '_result.tif']));

%% refresh
clc;clear;close all;imtool close all;

% Copyright 2018 The MathWorks, Inc.