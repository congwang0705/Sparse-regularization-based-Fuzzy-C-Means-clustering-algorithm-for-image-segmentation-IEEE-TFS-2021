%%
getd = @(p)path(p,path);
getd('images/');
getd('wavelets/');
getd('braindata/');
getd('BSDS300/images/test/');
getd('BSDS300/images/train/');
%%
clc
close all;    
clear all;
%% test a gray image 
f_ori=imread('sy2.bmp');

[row,col,h]=size(f_ori);
if h~=1
    f_ori=rgb2gray(f_ori);
end
figure(1);
imshow(f_ori);
%%
[counts_ori,x_ori]=imhist(f_ori);
figure(2);
imhist(f_ori);
%% add noise
fn=imnoise(f_ori,'gaussian',0,20^2/255^2);
fn=imnoise(fn,'salt & pepper',0.15);
fn = ricernd(double(fn), 0);
%fn=imread('0920_110_ori.tif');
figure(3);
imshow(uint8(fn));
%%
[counts_n,x_n]=imhist(fn);
figure(4);
imhist(fn);
%% parameter settings
cluster=4; 
lambda=0.01;
alpha=5; %filtering term coefficient
expo=2;
se=3; % the parameter of structuing element used for morphological reconstruction
%% step 1, morphological reconstruction
tic;
f_bar=w_recons_CO(double(fn),strel('square',se));
figure(5)
imshow(uint8(f_bar));
%%
[counts_bar,x_bar]=imhist(uint8(f_bar));%»Ò¶ÈÍ³¼Æ
figure(6);
imhist(uint8(f_bar));
%% step 2, feature extraction
Level=1;frame=1;
[D,R]=GenerateFrameletFilter(frame);nD=length(D);
W  = @(x) FraDecMultiLevel(x,D,Level); % Frame decomposition
WT = @(x) FraRecMultiLevel(x,R,Level); % Frame reconstruction
DATA1=[];DATA2=[];
W_1=W(double(fn));W_2=W(double(f_bar));
for i=1 : (nD-1)
    for j=1: (nD-1)
        fea1=reshape(W_1{1,1}{i,j},row*col,1);
        DATA1=[DATA1 fea1];
        
        fea1=reshape(W_2{1,1}{i,j},row*col,1);
        DATA2=[DATA2 fea1];
    end
end

%% step 3, fuzzy clustering
[U, center, dist, obj_fcn] = spfcm(DATA1,DATA2, cluster, expo, alpha, lambda);
[~, label] = max(U, [], 2);
%% step 4, label reconstruction
label=reshape(label, row, col,size(label,2));
figure(7);
imshow(label,[]);
label=w_recons_CO(double(label),strel('square',se));
figure(8);
imshow(label,[]);
%% step 5, image reconstruction
centerFull=center(label,:);
fs=reshape(centerFull, row, col,size(DATA1,2));
Recon{1,1}{1,1}=fs(:,:,1);Recon{1,1}{1,2}=fs(:,:,2);Recon{1,1}{1,3}=fs(:,:,3);
Recon{1,1}{2,1}=fs(:,:,4);Recon{1,1}{2,2}=fs(:,:,5);Recon{1,1}{2,3}=fs(:,:,6);
Recon{1,1}{3,1}=fs(:,:,7);Recon{1,1}{3,2}=fs(:,:,8);Recon{1,1}{3,3}=fs(:,:,9);
fs=WT(Recon);
figure(9);
imshow(uint8(fs));

center1=center(:,1);
fs=reshape(center1(label,:), row, col, 1);
%fs=w_recons_CO(double(fs),strel('square',se));
fs=medfilt2(uint8(fs),[3,3]);
fr=Optivalue(double(fs),cluster);
figure(10);
imshow(uint8(fr));