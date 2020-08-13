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
%% Correlation Plots
figure
subplot 121
hold on;
index_set1=1:8;
index_set2=9:1:16;
corrplot(nanmean(gRtTrialwise_sub(same.global.GsameLdiff,index_set1),2),nanmean(gRtTrialwise_sub(same.global.GsameLdiff,index_set2),2),[],1,'.r');% global same local diff
corrplot(nanmean(gRtTrialwise_sub(same.global.GsameLsame,index_set1),2),nanmean(gRtTrialwise_sub(same.global.GsameLsame,index_set2),2),[],1,'xr');% global same local same
corrplot(nanmean(gRtTrialwise_sub(diff.global.GdiffLsame,index_set1),2),nanmean(gRtTrialwise_sub(diff.global.GdiffLsame,index_set2),2),[],1,'.b'); % global diff Local same
corrplot(nanmean(gRtTrialwise_sub(diff.global.GdiffLdiff,index_set1),2),nanmean(gRtTrialwise_sub(diff.global.GdiffLdiff,index_set2),2),[],1,'xb'); % global diff Local diff
title('Global Block')
xlim([0.5,1.4]);
ylim([0.5,1.4]);
xlabel('Group-1');ylabel('Group-2')
subplot 122
corrplot(nanmean(lRtTrialwise_sub(same.local.GdiffLsame,index_set1),2),nanmean(lRtTrialwise_sub(same.local.GdiffLsame,index_set2),2),[],1,'.r');hold on;
corrplot(nanmean(lRtTrialwise_sub(same.local.GsameLsame,index_set1),2),nanmean(lRtTrialwise_sub(same.local.GsameLsame,index_set2),2),[],1,'xr');hold on;
corrplot(nanmean(lRtTrialwise_sub(diff.local.GsameLdiff,index_set1),2),nanmean(lRtTrialwise_sub(diff.local.GsameLdiff,index_set2),2),[],1,'.b');
corrplot(nanmean(lRtTrialwise_sub(diff.local.GdiffLdiff,index_set1),2),nanmean(lRtTrialwise_sub(diff.local.GdiffLdiff,index_set2),2),[],1,'xb');
title('Local Block')
xlim([0.5,1.4]);
ylim([0.5,1.4]);
xlabel('Group-1');ylabel('Group-2')

