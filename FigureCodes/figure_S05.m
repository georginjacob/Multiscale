% Code to generate MDS of visual search 
clc;clear all;close all;

load L2_VSmain.mat

% Images
images=L2_str.images;
% mean RT
RT=L2_str.RT.trial_wise;
RT_avg=nanmean(RT,3);
RT_avg_vector=mean(RT_avg,2);

% MDS Plot
simplot((1./RT_avg_vector),images,0.07)