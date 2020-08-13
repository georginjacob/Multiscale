% This code converts the input image given in a particular folder to
% matfile. Resizing capability is also included
clc;
clear all; close all;

% parameters
inFol='./images/faces/';
filename='tatcherFaces.mat';
M=500; % Output image size
N= 80;

% main code
stim=cell(N,1);
for ind=1:N
imgTemp=imread([inFol,num2str(ind),'.jpg']);
stim{ind}=imresize(imgTemp,[M,NaN]);
end 

% saving the result
save(filename,'stim') 