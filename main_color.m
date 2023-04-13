%%
getd = @(p)path(p,path);
%%
clc
close all;    
clear all;
%% test a gray image 
f_ori=imread('3.7-3.14.jpg');
%1_27_s.bmp 3_12_s.bmp
[row,col,h]=size(f_ori);
figure(1);
imshow(f_ori);
%% parameters
cluster=4; % the number of clustering centers
lambda=0.01;%%sparse term coefficient
alpha=5; %%filtering term coefficient
expo=2;
se=5; % the parameter of structuing element used for morphological reconstruction
%% step 1, morphological reconstruction
tic;
f_f=w_ColorRecons_CO(double(f_ori),se);
figure(2)
imshow(uint8(f_f));
ff=colorspace('Lab<-RGB',uint8(f_f));fo=colorspace('Lab<-RGB',uint8(f_ori));
figure(3)
imshow(uint8(fo));
figure(4)
imshow(uint8(ff));
%% step 2 feature extraction
Level=1; frame=1;
[D,R]=GenerateFrameletFilter(frame);nD=length(D);
W  = @(x) FraDecMultiLevel(x,D,Level); % Frame decomposition
WT = @(x) FraRecMultiLevel(x,R,Level); % Frame reconstruction

DATA1=[];DATA2=[];DATA3=[];
fr=fo(:,:,1); fg=fo(:,:,2); fb=fo(:,:,3);
W_1=W(double(fr));W_2=W(double(fg));W_3=W(double(fb));
for i=1 : (nD-1)
    for j=1: (nD-1)
        fea1=reshape(W_1{1,1}{i,j},row*col,1);
        DATA1=[DATA1 fea1];
        
        fea1=reshape(W_2{1,1}{i,j},row*col,1);
        DATA2=[DATA2 fea1];
        
        fea1=reshape(W_3{1,1}{i,j},row*col,1);
        DATA3=[DATA3 fea1];
    end
end
DATAo=[DATA1, DATA2, DATA3];


DATA1=[];DATA2=[];DATA3=[];
fr=ff(:,:,1); fg=ff(:,:,2); ff=fo(:,:,3);
W_1=W(double(fr));W_2=W(double(fg));W_3=W(double(fb));
for i=1 : (nD-1)
    for j=1: (nD-1)
        fea1=reshape(W_1{1,1}{i,j},row*col,1);
        DATA1=[DATA1 fea1];
        
        fea1=reshape(W_2{1,1}{i,j},row*col,1);
        DATA2=[DATA2 fea1];
        
        fea1=reshape(W_3{1,1}{i,j},row*col,1);
        DATA3=[DATA3 fea1];
    end
end
DATAf=[DATA1, DATA2, DATA3];
%% fuzzy clustering
[U, center, dist, obj_fcn] = spfcm(DATAo,DATAf, cluster, expo, alpha, lambda);
[~, label] = max(U, [], 2);
%% label reconstruction
label=reshape(label, row, col,size(label,2));
label=w_recons_CO(double(label),strel('square',se));
figure(5);
imshow(label,[]);
%%
center1=center(:,1);center2=center(:,10);center3=center(:,19);
center_lab=cat(3,center1,center2,center3);
centerf=255*colorspace('RGB<-Lab',center_lab);
fs=reshape(centerf(label, :), row, col, h);
figure(6);
imshow(uint8(fs));