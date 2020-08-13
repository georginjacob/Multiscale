% Global Advanatge and Incongruence Effect
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
%% GLOBAL ADVANTAGE EFFECT WITH MEAN AND ACCURACY COMPARISONS
% RT COMPARISON
fprintf('\n *************** Checking Global Advantage ******************')
data1=nanmean(gRtTrialwise_sub,1);data2=nanmean(lRtTrialwise_sub,1);
[P,H,STATS]=signrank(data1,data2,'tail','left','alpha',0.05);
fprintf('\n GB: mean±std=(%.2f,%.2f)ms,LB: mean±std=(%.2f,%.2f)ms',1000*nanmean(data1),1000*std(data1),1000*nanmean(data2),1000*std(data2));
fprintf('\n GB RT is significantly lower than LB RT |z|= %.2f, p=%.5f',abs(STATS.zval),P)
clear data1 data2

% ACCURACY COMPARISON
gAccuracy=L2_str.PC.total.global;
lAccuracy=L2_str.PC.total.local;
fprintf('\n\n Accuracy comparison across blocks, GB: mean±std=(%.2f,%.2f),LB: mean±std=(%.2f,%.2f)',100*nanmean(gAccuracy),100*std(gAccuracy),100*nanmean(lAccuracy),100*std(lAccuracy));
[P,H,STATS]=signrank(gAccuracy,lAccuracy,'tail','right','alpha',0.05,'method','approximate'); 
fprintf('\n Global block accuracy is significantly lower than Local Block |z|= %.2f, p=%.6f \n',(STATS.zval),P);
%% 
figure('units','normalized','outerposition',[0,0,1,1])
subplot(2,2,1)
% figure 2 B : Mean RT same and different blocks showing global advantage
data11=nanmean(gRtTrialwise_sub(same.global.GsameLsame,:),1);
data12=nanmean(lRtTrialwise_sub(same.local.GsameLsame,:),1);
mean_data(1,:)=[nanmean(data11),nanmean(data12)];
sem_data(1,:)=[nansem(data11,2),nansem(data12,2)];

data21=nanmean(gRtTrialwise_sub(diff.global.GdiffLdiff,:),1);
data22=nanmean(lRtTrialwise_sub(diff.local.GdiffLdiff,:),1);
mean_data(2,:)=[nanmean(data21),nanmean(data22)];
sem_data(2,:)=[nansem(data21,2),nansem(data22,2)];

bar(mean_data);
hold on;
errorbar([0.85,1.15;1.85,2.15],mean_data,sem_data,'.');
set(gca,'XTickLabel',{'GSLS','GDLD'})
title('Global Advantage')
ylabel('Mean Reaction Time,s');
legend({'Global','Local'},'Location','NorthEastOutside')
%% Global Advantage %%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n Global Advantage, GSLS, GB: mean±std=(%.3f,%.3f),LB: mean±std=(%.3f,%.3f)',nanmean(nanmean(gRtTrialwise_sub(same.global.GsameLsame,:),2)),nanstd(nanmean(gRtTrialwise_sub(same.global.GsameLsame,:),2)),nanmean(nanmean(lRtTrialwise_sub(same.local.GsameLsame,:),2)),nanstd(nanmean(lRtTrialwise_sub(same.local.GsameLsame,:),2)));
fprintf('\n\n Global Advantage, GDLD, GB: mean±std=(%.3f,%.3f),LB: mean±std=(%.3f,%.3f)',nanmean(nanmean(gRtTrialwise_sub(diff.global.GdiffLdiff,:),2)),nanstd(nanmean(gRtTrialwise_sub(diff.global.GdiffLdiff,:),2)),nanmean(nanmean(lRtTrialwise_sub(diff.local.GdiffLdiff,:),2)),nanstd(nanmean(lRtTrialwise_sub(diff.local.GdiffLdiff,:),2)));

Gx=nanmean(gRtTrialwise_sub(same.global.GsameLsame,:),2);
Lx=nanmean(lRtTrialwise_sub(same.local.GsameLsame,:),2);
fprintf('\n\n  %d of %d GSLS Image Pairs showed Global Advantage effect',length(find(Gx<Lx)),length(Gx))

Gx=nanmean(gRtTrialwise_sub(diff.global.GdiffLdiff,:),2);
Lx=nanmean(lRtTrialwise_sub(diff.local.GdiffLdiff,:),2);
fprintf('\n\n  %d of %d GDLD image pairs showed Global Advanatage Effect',length(find(Gx<Lx)),length(Gx))
%% %%%%%%%%%%%%%%%%%%%%%%%%%%% Incongruence Effect GDLD pairs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Incongruent Effect : Check on Global Diff, Local Diff Image pairs in both blocks
clear data11 data12 data21 data22

% Global Block
g1=GimagePairDetails(diff.global.GdiffLdiff,2);l1=GimagePairDetails(diff.global.GdiffLdiff,3);
g2=GimagePairDetails(diff.global.GdiffLdiff,4);l2=GimagePairDetails(diff.global.GdiffLdiff,5); % selecting g1,l1,g2,l2
index_C=diff.global.GdiffLdiff(g1==l1& g2==l2);index_I=diff.global.GdiffLdiff(g1==l2& g2==l1);% selecting the correct index
data11=nanmean(gRtTrialwise_sub(index_C,:),2);data12=nanmean(gRtTrialwise_sub(index_I,:),2);
mean_data_B(:,1)=[nanmean(data11),nanmean(data12)];sem_data_B(:,1)=[nansem(data11,1),nansem(data12,1)];
fprintf('\n %d of %d Image pairs showing incongruence in global block ', length(find(data11<data12)), length(data11))

% Local Block
g1=LimagePairDetails(diff.local.GdiffLdiff,2);l1=LimagePairDetails(diff.local.GdiffLdiff,3);
g2=LimagePairDetails(diff.local.GdiffLdiff,4);l2=LimagePairDetails(diff.local.GdiffLdiff,5); % selecting g1,l1,g2,l2
index_C=diff.local.GdiffLdiff(g1==l1& g2==l2);index_I=diff.local.GdiffLdiff(g1==l2& g2==l1);% selecting the correct index

data21=nanmean(lRtTrialwise_sub(index_C,:),2);data22=nanmean(lRtTrialwise_sub(index_I,:),2);
mean_data_B(:,2)=[nanmean(data21),nanmean(data22)];sem_data_B(:,2)=[nansem(data21,1),nansem(data22,1)];
fprintf('\n %d of %d Image pairs showing incongruence in local block ', length(find(data21<data22)), length(data21))

subplot (2,2,3)
bar(mean_data_B);
hold on;
errorbar([0.85,1.15;1.85,2.15],mean_data_B,sem_data_B,'.');
set(gca,'XTickLabel',{'global','local'})
title('Incongruence Effect GDLD pairs')
ylabel('Mean Reaction Time,s');
legend({'Conc','Inconc'},'Location','NorthEastOutside')

%% INTERFERENCE EFFECTS
clear mean_data sem_data
subplot (2,2,2)
% Local to Global Interference
data11=nanmean(gRtTrialwise_sub(same.global.GsameLsame,:),1);
data12=nanmean(gRtTrialwise_sub(same.global.GsameLdiff,:),1);
mean_data(1,:)=[nanmean(data11),nanmean(data12)];
sem_data(1,:)=[nansem(data11,2),nansem(data12,2)];

% Global to local interference
data21=nanmean(lRtTrialwise_sub(same.local.GsameLsame,:),1);
data22=nanmean(lRtTrialwise_sub(same.local.GdiffLsame,:),1);
mean_data(2,:)=[nanmean(data21),nanmean(data22)];
sem_data(2,:)=[nansem(data21,2),nansem(data22,2)];

subplot (2,2,2)
bar(mean_data);
hold on;
errorbar([0.85,1.15;1.85,2.15],mean_data,sem_data,'.');
set(gca,'XTickLabel',{'L. to G.','G. to L.'})
title('Interference Effect')
ylabel('Mean Reaction Time,s');
legend({'Conc','Inconc'},'Location','NorthEastOutside')

local_to_global_inferference=nanmean(gmeanRT(same.global.GsameLdiff))-nanmean(gmeanRT(same.local.GsameLsame));
fprintf('\n Local to global interferrence %.4f (difference in mean, GSLD-GDLS in GB)\n',local_to_global_inferference)

global_to_local_interference=nanmean(lmeanRT(same.local.GdiffLsame))-nanmean(lmeanRT(same.local.GsameLsame));
fprintf('\n Global to Local interference %.4f (difference in the mean, GDLS-GSLS in LB)\n',global_to_local_interference);

%% means of each set
fprintf('\n GSLS pairs mean+-std= %.3f,%.3f (GB), %.3f, %.3f (LB)',nanmean(gmeanRT(same.global.GsameLsame)),nanstd(gmeanRT(same.global.GsameLsame)),nanmean(lmeanRT(same.local.GsameLsame)),nanstd(lmeanRT(same.local.GsameLsame)));

fprintf('\n GDLD pairs mean+-std= %.3f,%.3f (GB), %.3f, %.3f (LB)',nanmean(gmeanRT(diff.global.GdiffLdiff)),nanstd(gmeanRT(diff.global.GdiffLdiff)),nanmean(lmeanRT(diff.local.GdiffLdiff)),nanstd(lmeanRT(diff.local.GdiffLdiff)));

fprintf('\n GSLD pairs mean+-std= %.3f,%.3f (GB), %.3f, %.3f (LB)',nanmean(gmeanRT(same.global.GsameLdiff)),nanstd(gmeanRT(same.global.GsameLdiff)),nanmean(lmeanRT(diff.local.GsameLdiff)),nanstd(lmeanRT(diff.local.GsameLdiff)));

fprintf('\n GDLS pairs mean+-std= %.3f,%.3f (GB), %.3f, %.3f (LB)',nanmean(gmeanRT(diff.global.GdiffLsame)),nanstd(gmeanRT(diff.global.GdiffLsame)),nanmean(lmeanRT(same.local.GdiffLsame)),nanstd(lmeanRT(same.local.GdiffLsame)));
%% Global Local incongruence in same RT
clear mean_data sem_data
% global block
g1=GimagePairDetails(same.global.GsameLsame,2);l1=GimagePairDetails(same.global.GsameLsame,3);
g2=GimagePairDetails(same.global.GsameLsame,4);l2=GimagePairDetails(same.global.GsameLsame,5); % selecting g1,l1,g2,l2
index_C=same.global.GsameLsame(g1==l1);index_I=same.global.GsameLsame(g1~=l1);% This condition is selected assuming GSLS

dataC=nanmean(gRtTrialwise_sub(index_C,:));
dataI=nanmean(gRtTrialwise_sub(index_I,:));
mean_data(1,:)=[nanmean(dataC),nanmean(dataI)];
sem_data(1,:)=[nansem(dataC,2),nansem(dataI,2)];

fprintf('\n\n Incongruence, GSLS(GB), Conc: mean±std=(%.3f,%.3f),Inconc: mean±std=(%.3f,%.3f)',nanmean(nanmean(gRtTrialwise_sub(index_C,:),2)),nanstd(nanmean(gRtTrialwise_sub(index_C,:),2)),nanmean(nanmean(gRtTrialwise_sub(index_I,:),2)),nanstd(nanmean(gRtTrialwise_sub(index_I,:),2)));

g1=LimagePairDetails(same.local.GsameLsame,2);l1=LimagePairDetails(same.local.GsameLsame,3);
g2=LimagePairDetails(same.local.GsameLsame,4);l2=LimagePairDetails(same.local.GsameLsame,5); % selecting g1,l1,g2,l2
index_C=same.local.GsameLsame(g1==l1);index_I=same.local.GsameLsame(g1~=l1);% This condition is selected assuming GSLS

dataC=nanmean(lRtTrialwise_sub(index_C,:));
dataI=nanmean(lRtTrialwise_sub(index_I,:));
mean_data(2,:)=[nanmean(dataC),nanmean(dataI)];
sem_data(2,:)=[nansem(dataC,2),nansem(dataI,2)];

subplot (2,2,4)
bar(mean_data);
hold on;
errorbar([0.85,1.15;1.85,2.15],mean_data,sem_data,'.');
set(gca,'XTickLabel',{'Global','Local'})
title('Incongruence Effect (GSLS)')
ylabel('Mean Reaction Time,s');
legend({'Conc','Inconc'},'Location','NorthEastOutside')
ylim([0,0.75])

fprintf('\n\n Incongruence, GSLS(LB), Conc: mean±std=(%.3f,%.3f),Inconc: mean±std=(%.3f,%.3f)',nanmean(nanmean(lRtTrialwise_sub(index_C,:),2)),nanstd(nanmean(lRtTrialwise_sub(index_C,:),2)),nanmean(nanmean(lRtTrialwise_sub(index_I,:),2)),nanstd(nanmean(lRtTrialwise_sub(index_I,:),2)));

