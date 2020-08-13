% Consistency
clc; clear all; close all;

addpath ./subfunctions/

% Loading the data
load L2_VSmain.mat; L2_str_GL=L2_str;clear L2_str;% Read Visual search data
load L2_SD;% Read SD exp data
images=L2_str.images; % 49 stim

[same,diff,gmeanRT,lmeanRT,GimagePairDetails,LimagePairDetails,GimagePairs,LimagePairs,consistency_table,gRtTrialwise_sub,lRtTrialwise_sub,~,gRtTrialwise,lRtTrialwise]=pre_process_SD_TASK(L2_str); % pre process the data
[GL_gRT,GL_lRT,GL_rt,GL_img_pair_details,GL_gPC,GL_lPC]=arrange_GL_data(L2_str_GL,GimagePairDetails,LimagePairDetails); % arrange the data
GL_gmeanRT=nanmean(GL_gRT,2);
GL_lmeanRT=nanmean(GL_lRT,2);

%% comparing identical image pairs across blocks
figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6])
corrplot(gmeanRT(same.global.GsameLdiff),lmeanRT(diff.local.GsameLdiff),[],1,'xr')
hold on;
corrplot(gmeanRT(diff.global.GdiffLsame),lmeanRT(same.local.GdiffLsame),[],1,'xg')
%title('Opposite Response for Image Pairs')
xlabel('Global Block')
ylabel('Local BLock');
axis([0.5,1.1,0.5,1.1])
legend('GSLD','','','GDLS','','');
figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6])
corrplot(gmeanRT(same.global.GsameLsame),lmeanRT(same.local.GsameLsame),'SAME',1,'xr')
corrplot(gmeanRT(diff.global.GdiffLdiff),lmeanRT(diff.local.GdiffLdiff),'DIFF',1,'xg')
xlabel('Global BLock');
ylabel('Local Block');