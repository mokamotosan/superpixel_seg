function [xaxis, yaxis, yaxis2] = get_inerseg_newmachine(imgfile)
%% mySuperPixel_seg.m
% created by Kei. Ohtsuka@MathWorks
% modified by M. Okamoto@FMU
% �O���C�X�P�[���摜�p

imgfile = 'Original0000.bmp';

%% �摜�̓Ǎ��݁E�\��
I = imread(imgfile);
%figure; imshow(I);

%% �f�[�^�^�ϊ�
I = im2double(I);

%% ���[���g���~���O
Itrim = I(:, 50:450);

%% ���̗v�f�����o
%���̗v�f�����o
fib = Itrim < 0.7;
BWtrim = bwareaopen(fib, 80);

%% �X�[�p�[�s�N�Z����p�����̈�ɕ���
%    �ڕW�F�����T�C�Y�́A1000�̗ގ��F�̈�ɂȂ�悤�ɕ���
[L, N] = superpixels(Itrim, 1000, 'IsInputLab',true);     % �f�t�H���g�ł͓�����L*a*b*�֕ϊ�
N;                             % N :���ʓI�ɐ������ꂽ�X�[�p�[�s�N�Z����
imtool(L, []);                % Ls:���x���摜

%% �X�[�p�[�s�N�Z���̕\��
Bmask = boundarymask(L);             % ���x�����E���g���[�X�i2�l�摜�j
I1 = imoverlay(BWtrim, Bmask,'cyan');      % �摜���ɁA2�l�摜���w��F�ŏ㏑��
%figure;imshow(I1); shg;

%% �X�[�p�[�s�N�Z�����ɕ��ϒl���Z�o���A���ω�
rng('default')
pixelIdxList = label2idx(L);
meanColor = zeros(N,1);
for  i = 1:N
    meanColor(i,1) = mean(BWtrim(pixelIdxList{i}));
end

%% K-means���g���ăN���X�^�����O
numColors = 2;
[idx,~] = kmeans(meanColor,numColors,'replicates',3);
Lout = zeros(size(BWtrim,1),size(BWtrim,2));
for i = 1:N
    Lout(pixelIdxList{i}) = idx(i);
end
% imshow(label2rgb(Lout))
% figure, imshow(BWtrim)

%% �֘A�̈�I��
bw = Lout == 2;
bw = imclose(bw, strel('disk',3));
%imshow(bw)

%% �֐S�̈�̑I��
bw2 = bwpropfilt(bw, 'MajorAxisLength', 1);
%imshow(bw2);

%% ���W���
stats = regionprops(bw2, 'Extrema');
% top-left, top-right�𒊏o
xy = stats.Extrema([8,1,2,3],:);
% for i = 1:size(stats,1)
%     xy(i*2-1:i*2,:) = stats(i).Extrema([8,1,2,3],:);
% end
I2 = insertMarker(Itrim,xy,'circle');
figure, imshow(I2)

%% �t�B�b�e�B���O
%cftool(xy(:,1),xy(:,2));
ft = fittype( 'poly1' );
% ���f�����f�[�^�ɋߎ����܂��B
fittedmodel = fit(xy(:,1),xy(:,2),ft);
% �ߎ��Ȑ��̃f�[�^������
xaxis = (1:size(I,2))';
yaxis = fittedmodel(xaxis);
% �ߎ��Ȑ����ŊO���_��ʂ�悤�ɕ␳
[~, idx] = min(xy(:,2));
xy_outer = xy(idx,:);
yaxis = yaxis + xy_outer(2) - fittedmodel(xy_outer(1));

% �����Ȓ���������
yaxis2 = ones(size(xaxis))*xy_outer(2);

% %% ���W���
% bw4 = bwmorph(bw3, 'skel', 'Inf');
% [r, c] = find(bw4);
% 
% imshow(bw3)
% figure, imshow(BWtrim)
% 
% %% �t�B�b�e�B���O
% %cftool(xy(:,1),xy(:,2));
% ft = fittype( 'poly2' );
% % ���f�����f�[�^�ɋߎ����܂��B
% fittedmodel = fit(c,r,ft);
% 
% %% ���ʏ㏑��
% xaxis = 1:size(I,2);
% yaxis = fittedmodel(xaxis);
% plot(xaxis, yaxis, 'g', 'LineWidth', 2);


%% ���ʏ㏑��
% fh = figure; imshow(BWtrim);
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