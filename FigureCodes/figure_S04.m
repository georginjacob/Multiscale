% SD task model code.
% Last modified 16-05-2018
clc; clear all; close all;
addpath ./subfunctions/
load L2_VSmain.mat; L2_str_GL=L2_str;clear L2_str;% Read Visual search data
load L2_SD;% Read SD exp data
images=L2_str.images; % 49 stim
[same,diff,gmeanRT,lmeanRT,GimagePairDetails,LimagePairDetails,GimagePairs,LimagePairs,consistency_table,gRtTrialwise_sub,lRtTrialwise_sub]=pre_process_SD_TASK(L2_str); % pre process the data
[GL_gRT,GL_lRT,GL_rt,GL_img_pair_details,GL_gPC,GL_lPC]=arrange_GL_data(L2_str_GL,GimagePairDetails,LimagePairDetails); % arrange the data
GL_gmeanRT=nanmean(GL_gRT,2);
GL_lmeanRT=nanmean(GL_lRT,2);
%% distinctiveness in visual search
GL_dobs=1./GL_rt;
Nshape=7;GL_stim_details(:,1)=repmat([1:Nshape]',Nshape,1); % global
GL_stim_details(:,2)=vec(repmat(1:Nshape,Nshape,1)); % local
stim=1:49;
[GL_DG,GL_DL]=distinctiveness(stim,GL_stim_details,GL_dobs,GL_img_pair_details);
[GL_dpred,GL_model]=FitBatonModel(GL_dobs,L2_str_GL.Image_Pair_Details);
%%
DG=1./gmeanRT(same.global.GsameLsame);
DL=1./lmeanRT(same.local.GsameLsame);
estDist=[DG,DL];
figure('Name','S4','units','normalized','outerposition',[0 0 1 1])
for ind =1:4
    switch(ind)
        case 1
            title_str{ind}='Global-Same: GSLD pairs';
            index=same.global.GsameLdiff;
            img_pair_details=GimagePairDetails(index,2:5);
            img_pair=GimagePairs(index,:);
            [sumD]= compute_D_dist(DG,[],[],img_pair,img_pair_details);
            obsRT=gmeanRT(index);
            subplot(2,2,1);corrplot(sumD,obsRT,title_str{ind});xlabel('sum of GD');ylabel('Observed RT');
        case 2
            title_str{ind}='Global-Diff';
            index=find(GimagePairDetails(:,1)==1);
            img_pair=GimagePairs(index,:);
            img_pair_details=GimagePairDetails(index,2:5);
            obsRT=gmeanRT(index);
            [sumD]= compute_D_dist(DG,[],[],img_pair,img_pair_details);
            subplot(2,2,2),corrplot(sumD,obsRT,title_str{ind});xlabel('sum of GD');ylabel('Observed RT');
            
            % Adding congruent-incongruent plots
            g1=img_pair_details(:,1);l1=img_pair_details(:,2);
            g2=img_pair_details(:,3);l2=img_pair_details(:,4);
            conc_index=find(g1==l1&g2==l2);conc_stim_pair=GimagePairs(index(conc_index),:);
            inconc_index=find(g1==l2&g2==l1);inconc_stim_pair=GimagePairs(index(inconc_index),:);
            hold on;
            plot(sumD(conc_index),obsRT(conc_index),'ro');
            plot(sumD(inconc_index),obsRT(inconc_index),'go');
        case 3
            title_str{ind}='Local-Same : GDLS pairs';
            %index=find(LimagePairDetails(:,1)==0);
            index=same.local.GdiffLsame;
            img_pair_details=LimagePairDetails(index,2:5);
            img_pair=LimagePairs(index,:);
            obsRT=lmeanRT(index);
            [sumL]= compute_D_dist(DL,[],[],img_pair,img_pair_details);
            subplot(2,2,ind),corrplot(sumL,obsRT,title_str{ind});xlabel('sum of LD');ylabel('Observed RT');
        case 4
            title_str{ind}='Local-Diff';
            index=find(LimagePairDetails(:,1)==1);img_pairs=LimagePairs(index,:);
            obsRT=lmeanRT(index);
            img_pair_details=LimagePairDetails(index,2:5);
            img_pair=LimagePairs(index,:);
            [sumL]= compute_D_dist(DL,[],[],img_pair,img_pair_details);
            subplot(2,2,ind),corrplot(sumL,obsRT,title_str{ind});xlabel('sum of LD');ylabel('Observed RT');
            
            g1=img_pair_details(:,1);l1=img_pair_details(:,2);
            g2=img_pair_details(:,3);l2=img_pair_details(:,4);
            conc_index=find(g1==l1&g2==l2);conc_stim_pair=img_pair(conc_index,:);
            inconc_index=find(g1==l2&g2==l1);inconc_stim_pair=img_pair(inconc_index,:);
            hold on;
            plot(sumL(conc_index),obsRT(conc_index),'ro');
            plot(sumL(inconc_index),obsRT(inconc_index),'go');
            
    end
end
%% Checking the congruence in distinctiveness
g1=L2_str_GL.Image_Pair_Details(:,1);l1=L2_str_GL.Image_Pair_Details(:,2);
g2=L2_str_GL.Image_Pair_Details(:,3);l2=L2_str_GL.Image_Pair_Details(:,4);
conc_index=find(g1==l1&g2==l2);conc_stim_pair=L2_str_GL.img_pairs(conc_index,:);
inconc_index=find(g1==l2&g2==l1);inconc_stim_pair=L2_str_GL.img_pairs(inconc_index,:);

Ncond=length(conc_index);
GD_conc_pairs.global=zeros(Ncond,1);
GD_inconc_pairs.global=zeros(Ncond,1);
GD_conc_pairs.local=zeros(Ncond,1);
GD_inconc_pairs.local=zeros(Ncond,1);
for ind= 1:Ncond
    ipc=conc_stim_pair(ind,:);
    GD_conc_pairs.global(ind)=DG(ipc(1))+DG(ipc(2));% global
    GD_conc_pairs.local(ind)=DL(ipc(1))+DL(ipc(2));% local
    ipi=inconc_stim_pair(ind,:);
    GD_inconc_pairs.global(ind)=DG(ipi(1))+DG(ipi(2));
    GD_inconc_pairs.local(ind)=DL(ipi(1))+DL(ipi(2));
end

figure;
subplot 121
mean_data=[nanmean(GD_conc_pairs.global),nanmean(GD_inconc_pairs.global)];
std_data=[nanstd(GD_conc_pairs.global),nanstd(GD_inconc_pairs.global)];
bar(mean_data);hold on;
errorbar(mean_data,std_data);
xlabel('Conc---- inconc');ylabel('Average of Global distinctiveness');title('Global');
subplot 122
mean_data=[nanmean(GD_conc_pairs.local),nanmean(GD_inconc_pairs.local)];
std_data=[nanstd(GD_conc_pairs.local),nanstd(GD_inconc_pairs.local)];
bar(mean_data);hold on;errorbar(mean_data,std_data);
xlabel('Conc---- inconc');ylabel('Average of Local distinctiveness');title('Local');
ranksum(GD_conc_pairs.global,GD_inconc_pairs.global)
ranksum(GD_conc_pairs.local,GD_inconc_pairs.local)
