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
%% FIT SD model
% estimating the global and local distinctiveness from the identical same
% trials.
DG=1./gmeanRT(same.global.GsameLsame);
DL=1./lmeanRT(same.local.GsameLsame);
estDist=[DG,DL];
figure(1);
subplot 121
imagesc(reshape(DG,[7,7]));colorbar;
set(gca,'YTickLabel',{'G-diamond','G-square','G-A','G-Circle','G-X','G-N','G-Z'},'YTickLabelRotation',45);title('GB: Actual Stimulus distinctiveness')
set(gca,'XTickLabel',{'L-diamond','L-square','L-A','L-Circle','L-X','L-N','L-Z'},'XTickLabelRotation',45);
subplot 122
imagesc(reshape(DL,[7,7]));colorbar;
set(gca,'XTickLabel',{'L-diamond','L-square','L-A','L-Circle','L-X','L-N','L-Z'},'XTickLabelRotation',45);title('LB: Actual Stimulus distinctiveness')
set(gca,'YTickLabel',{'G-diamond','G-square','G-A','G-Circle','G-X','G-N','G-Z'},'YTickLabelRotation',45);

%% GLOBAL BLOCK
% Same RT
title_str=cell(4,1);
data_errorbar=zeros(5,4);
data_upper_lower_limit=zeros(4,2);
data_mean=zeros(5,4);
aicc_values=zeros(4,2);% mean std
partial_corr=[];
for ind=1:4
    switch(ind)
        case 2
            title_str{ind}='Global-Diff';
            index=find(GimagePairDetails(:,1)==1);
            obsRT=gmeanRT(index);
            img_pair=GimagePairs(index,:);
            img_pair_details=GimagePairDetails(index,2:5);
            [sd_coeff.global.diff,preRT,X]=FitSD_combined(obsRT,estDist,img_pair,img_pair_details,12);
            % partial correlation
            Gdist=sd_coeff.global.diff(1+1+(1:21)); % estimating dissimilarity from similarity
            Ldist=sd_coeff.global.diff(1+1+21+(1:21));
            partial_corr.global.diff = find_partial_correlation(obsRT,DG,DL,Gdist,Ldist,img_pair,img_pair_details,12);
            figure(5);subplot(1,4,ind);bar(partial_corr.global.diff(:,1));
            dm=partial_corr.global.diff(:,1);LL=dm-partial_corr.global.diff(:,3);UL=partial_corr.global.diff(:,4)-dm;PV=partial_corr.global.diff(:,2);
        case 4
            
            title_str{ind}='Local-Diff';
            index=find(LimagePairDetails(:,1)==1);img_pairs=LimagePairs(index,:);
            obsRT=lmeanRT(index);
            img_pair_details=LimagePairDetails(index,2:5);
            img_pair=LimagePairs(index,:);
            [sd_coeff.local.diff,preRT,X]=FitSD_combined(obsRT,estDist,img_pair,img_pair_details,22);
            % partial correlation
            Gdist=sd_coeff.local.diff(1+1+(1:21));% estimating dissimilarity from similarity
            Ldist=sd_coeff.local.diff(1+1+21+(1:21));
            partial_corr.local.diff = find_partial_correlation(obsRT,DG,DL,Gdist,Ldist,img_pair,img_pair_details,22);
            % plotting
            dm=partial_corr.local.diff(:,1);LL=dm-partial_corr.local.diff(:,3);UL=partial_corr.local.diff(:,4)-dm;PV=partial_corr.local.diff(:,2);
            figure(5);subplot(1,4,ind);bar(partial_corr.local.diff(:,1));
        case 1
            title_str{ind}='Global-Same: GSLD pairs';
            % index=find(GimagePairDetails(:,1)==0);
            index=same.global.GsameLdiff;
            img_pair_details=GimagePairDetails(index,2:5);
            img_pair=GimagePairs(index,:);
            obsRT=gmeanRT(index);
            [sd_coeff.global.same,preRT,X]=FitSD_combined(obsRT,estDist,img_pair,img_pair_details,11);
            % partial correlation
            Gdist=zeros(21,1);
            Ldist=sd_coeff.global.same(1+1+(1:21));
            partial_corr.global.same = find_partial_correlation(obsRT,DG,DL,Gdist,Ldist,img_pair,img_pair_details,11);
            figure(5);subplot(1,4,ind);bar(partial_corr.global.same(:,1));
            dm=partial_corr.global.same(:,1);LL=dm-partial_corr.global.same(:,3);UL=partial_corr.global.same(:,4)-dm;PV=partial_corr.global.same(:,2);
            
        case 3
            title_str{ind}='Local-Same : GDLS pairs';
            %index=find(LimagePairDetails(:,1)==0);
            index=same.local.GdiffLsame;
            img_pair_details=LimagePairDetails(index,2:5);
            img_pair=LimagePairs(index,:);
            obsRT=lmeanRT(index);
            [sd_coeff.local.same,preRT,X]=FitSD_combined(obsRT,estDist,img_pair,img_pair_details,21);
            % partial correlation
            Ldist=zeros(21,1);
            Gdist=sd_coeff.local.same(1+1+(1:21));
            partial_corr.local.same = find_partial_correlation(obsRT,DG,DL,Gdist,Ldist,img_pair,img_pair_details,21);
            figure(5);subplot(1,4,ind);bar(partial_corr.local.same(:,1));
            dm=partial_corr.local.same(:,1);LL=dm-partial_corr.local.same(:,3);UL=partial_corr.local.same(:,4)-dm;PV=partial_corr.local.same(:,2);% limits
            
    end
    figure(6);subplot(2,2,ind);corrplot(preRT,obsRT,title_str{ind},1);ylabel('Observed RT, s');xlabel('Predicted RT, s'); axis([0.55,1,0.55,1]);
    set(gca,'XTick',[0.55,1],'Ytick',[0.55,1])
    figure(5);title(title_str{ind});set(gca,'XTickLabel',{'GD','LD','gdist','ldist'});   ylabel('Partial Correlation with Observerd RT ');ylim([-1,1])
    % errorbar
    hold on;
    for i=1:length(UL)
        e=errorbar(i,dm(i),LL(i),UL(i));
    end
    set(e,'Marker','none','Linestyle','none','Color','k');
    % p-value
    for i=1:length(PV)
        text(i,dm(i),num2str(PV(i)));
    end
    Lc=size(X,2);
    [am,as,ba] = aicc(preRT,obsRT,Lc);aicc_values(ind,1)=am;aicc_values(ind,2)=as;
    [C,P,RL,RU  ]=corrcoef(obsRT,preRT,'alpha',0.3173);
end