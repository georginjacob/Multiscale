% This code is for the following
% Note: Change to code plot everything across subject but decided not to do
% it.

% Figure 2. Main global-local experiment (now Expt 2) 
% A.	Example search array
% B.	Average RT for global-different & local-different searches
% C.	Average RT of congruent/incongruent searches
clc;clear all;close all;
%ddpath ./subfunctions/
load L2_VSmain.mat; %L2_str_GL=L2_str;clear L2_str;
%load('L2_str');
imagePairDetails=L2_str.Image_Pair_Details;
rtTrialwise=L2_str.RT.trial_wise;
rt_sub=nanmean(rtTrialwise,3);
g1=imagePairDetails(:,1);
l1=imagePairDetails(:,2);
g2=imagePairDetails(:,3);
l2=imagePairDetails(:,4);

% Local Change
indexLc=find(g1==g2);rtLocalchange_sub=nanmean(rt_sub(indexLc,:),1)';rtLocalchange=nanmean(rt_sub(indexLc,:),2);
% Global Change
indexGc=find(l1==l2);rtGlobalchange_sub=nanmean(rt_sub(indexGc,:),1)';rtGlobalchange=nanmean(rt_sub(indexGc,:),2);
% congruent
indexC=find(g1==l1 & g2==l2);rtConc_sub=nanmean(rt_sub(indexC,:),1)';rtConc=nanmean(rt_sub(indexC,:),2);
% incongruent
indexI=find(g1==l2 & g2==l1);rtInconc_sub=nanmean(rt_sub(indexI,:),1)';rtInconc=nanmean(rt_sub(indexI,:),2);
clear indexLc indexGc indexC
fprintf('\n Congruent searches were faster than incongruent searches, mean+-std %.3f +- %.3f(congruent),mean+-std %.3f +- %.3f(incongruent)',nanmean(rtConc),nanstd(rtConc),nanmean(rtInconc),nanstd(rtInconc))

rt_A_B_sub=rtTrialwise(:,:,1);
rt_B_A_sub=rtTrialwise(:,:,2);
rt_A_B=nanmean(rtTrialwise(:,:,1),2);
rt_B_A=nanmean(rtTrialwise(:,:,2),2);

Nsub=size(rt_A_B_sub,2);

for i=1:Nsub
RT_AB=triu(squareform(rt_A_B_sub(:,i)),1);
RT_BA=tril(squareform(rt_B_A_sub(:,i)),-1);
RT_TD(:,:,i)=RT_AB+RT_BA;
end

%% Incongruence
shapes=1:7;
pairs=nchoosek(shapes,2);
pN=length(pairs);
%% TARGET CONGRUENCE
% mean RT,c:congruent, i: incongruent T/D: target/distractor
mRT_cTiD=zeros(pN,40,Nsub);
mRT_iTiD=zeros(pN,40,Nsub);

stdRTconc=zeros(pN,4);
for p=1:length(pairs)  
target_shapes=pairs(p,:);
distractor_shapes=setdiff(shapes,target_shapes);
% shape pairs 
concTarget=[target_shapes',target_shapes']; % Global, Local
inconcTarget=[target_shapes;fliplr(target_shapes)]; % Global, Local
inconcDistractor=[nchoosek(distractor_shapes,2);fliplr(nchoosek(distractor_shapes,2))];
% images
imgcT=GLshapes_imgID(concTarget);
imgiT=GLshapes_imgID(inconcTarget);
imgiD=GLshapes_imgID(inconcDistractor);

% image Pairs
imgPairs_cTiD=image_pairs(imgcT,imgiD);
imgPairs_iTiD=image_pairs(imgiT,imgiD);

% RTs
RT_cTiD=fetch_RT(imgPairs_cTiD, RT_TD);
RT_iTiD=fetch_RT(imgPairs_iTiD, RT_TD);

mRT_cTiD(p,:,:)=(RT_cTiD);
mRT_iTiD(p,:,:)=(RT_iTiD);
end

mRT_cTiD_pairs_sub=squeeze(nanmean(mRT_cTiD,2)); % averaging across conditions
mRT_iTiD_pairs_sub=squeeze(nanmean(mRT_iTiD,2)); % averaging across conditions


mRT_cTiD_sub=squeeze(nanmean(mRT_cTiD,[1,2])); % averaging across pairs and conditions
mRT_iTiD_sub=squeeze(nanmean(mRT_iTiD,[1,2])); % averaging across pairs and conditions

mRT_cTiD=squeeze(nanmean(mRT_cTiD,[3])); % averaging across pairs and conditions
mRT_iTiD=squeeze(nanmean(mRT_iTiD,[3])); % averaging across pairs and condi


fprintf('\n Target congruence comparison, mean+-std %.3f +- %.3f(congruent),mean+-std %.3f +- %.3f(incongruent)',nanmean(mRT_cTiD(:)),nanstd(mRT_cTiD(:)),nanmean(mRT_iTiD(:)),nanstd(mRT_iTiD(:)))


clear target_shapes distractor_shapes concTarget inconcTarget inconcDistractor RT_cTiD RT_iTiD
%% DISTRACTOR CONGRUENCE
% mean RT,c:congruent, i: incongruent T/D: target/distractor
mRT_cDiT=zeros(pN,40,Nsub);
mRT_iDiT=zeros(pN,40,Nsub);

for p=1:length(pairs)  
distractor_shapes=pairs(p,:);
target_shapes=setdiff(shapes,distractor_shapes);
% shape pairs 
concDistractor=[distractor_shapes',distractor_shapes']; % Global, Local
inconcDistractor=[distractor_shapes;fliplr(distractor_shapes)]; % Global, Local
inconcTarget=[nchoosek(target_shapes,2);fliplr(nchoosek(target_shapes,2))];
% images
imgcD=GLshapes_imgID(concDistractor);
imgiD=GLshapes_imgID(inconcDistractor);
imgiT=GLshapes_imgID(inconcTarget);

% image Pairs
imgPairs_cDiT=image_pairs(imgiT,imgcD);
imgPairs_iDiT=image_pairs(imgiT,imgiD);

% RTs
RT_cDiT=fetch_RT(imgPairs_cDiT, RT_TD);
RT_iDiT=fetch_RT(imgPairs_iDiT, RT_TD);

mRT_cDiT(p,:,:)=(RT_cDiT);
mRT_iDiT(p,:,:)=(RT_iDiT);
end

mRT_cDiT_pairs_sub=squeeze(nanmean(mRT_cDiT,2)); % averaging across  conditions
mRT_iDiT_pairs_sub=squeeze(nanmean(mRT_iDiT,2)); % averaging across  conditions


mRT_cDiT_sub=squeeze(nanmean(mRT_cDiT,[1,2])); % averaging across pairs and conditions
mRT_iDiT_sub=squeeze(nanmean(mRT_iDiT,[1,2])); % averaging across pairs and conditions

mRT_cDiT=squeeze(nanmean(mRT_cDiT,[3])); % averaging across subjects and distractor
mRT_iDiT=squeeze(nanmean(mRT_iDiT,[3])); % averaging across subjects and distractor


fprintf('\n Distractor congruence comparison, mean+-std %.3f +- %.3f(congruent),mean+-std %.3f +- %.3f(incongruent)',nanmean(mRT_cDiT(:)),nanstd(mRT_cDiT(:)),nanmean(mRT_iDiT(:)),nanstd(mRT_iDiT(:)))
%% Saving CSV for R-analysis
Data_cTiD={};
Data_iTiD={};

Data_cDiT={};
Data_iDiT={};
count=0;
for sub=1:Nsub
    for p=1:21
        count=count+1;
        % Target Congruence
        % congruent
        Data_cTiD{count,1}=p;
        Data_cTiD{count,2}=sub;
        Data_cTiD{count,3}='D.Incongruent';
        Data_cTiD{count,4}='T.Congruent';
        Data_cTiD{count,5}=mRT_cTiD_pairs_sub(p,sub);
        % incongreunt 
        Data_iTiD{count,1}=p;
        Data_iTiD{count,2}=sub;
        Data_iTiD{count,3}='D.Incongruent';
        Data_iTiD{count,4}='T.Incongruent';
        Data_iTiD{count,5}=mRT_iDiT_pairs_sub(p,sub);        
        
        % Distractor Congruence
        % congruent
        Data_cDiT{count,1}=p;
        Data_cDiT{count,2}=sub;
        Data_cDiT{count,3}='D.Congruent';
        Data_cDiT{count,4}='T.Incongruent';
        Data_cDiT{count,5}=mRT_cDiT_pairs_sub(p,sub);
        % incongreunt 
        Data_iDiT{count,1}=p;
        Data_iDiT{count,2}=sub;
        Data_iDiT{count,3}='D.Incongruent';
        Data_iDiT{count,4}='T.Incongruent';
        Data_iDiT{count,5}=mRT_iDiT_pairs_sub(p,sub);

    end
end
DataTarget=[Data_cTiD;Data_iTiD];
DataDistractor=[Data_cDiT;Data_iDiT];
Table_Target=cell2table(DataTarget,'VariableNames',{'ShapePairs','Subject','Distractor','Target','meanRT'});
Table_Distractor=cell2table(DataDistractor,'VariableNames',{'ShapePairs','Subject','Distractor','Target','meanRT'});
writetable(Table_Target,'VS_target_congruence.csv');
writetable(Table_Distractor,'VS_distractor_congruence.csv');
%%
figure('name','Figure-04');
subplot 221;
bar([nanmean(rtGlobalchange_sub),nanmean(rtLocalchange_sub)]);hold on;;ylabel('mean RT');title('Global Advanatge');
errorbar([nanmean(rtGlobalchange_sub),nanmean(rtLocalchange_sub)],[nansem(rtGlobalchange_sub),nansem(rtLocalchange_sub)],'r.')
h=gca;h.XTickLabel={'Global','Local'};
ylim([0,2.5])

subplot 222;
bar([nanmean(rtConc_sub),nanmean(rtInconc_sub)]);hold on;ylabel('mean RT');title('Incongruence');
errorbar([nanmean(rtConc_sub),nanmean(rtInconc_sub)],[nansem(rtConc_sub),nansem(rtInconc_sub)],'r.')
h=gca;h.XTickLabel={'Conc','Inconc'};
ylim([0,1.5])


subplot 223;

bar([nanmean(mRT_cTiD_sub),nanmean(mRT_iTiD_sub)]);hold on;ylabel('mean RT');title('Target Incongruence')
errorbar([nanmean(mRT_cTiD_sub),nanmean(mRT_iTiD_sub)],[nansem(mRT_cTiD_sub),nansem(mRT_iTiD_sub)],'r.')
h=gca;h.XTickLabel={'Conc','Inconc'};
ylim([0,1.5])

subplot 224;

bar([nanmean(mRT_cDiT_sub),nanmean(mRT_iDiT_sub)]);hold on;ylabel('mean RT');title('Distractor Incongruence')
errorbar([nanmean(mRT_cDiT_sub),nanmean(mRT_iDiT_sub)],[nansem(mRT_cDiT_sub),nansem(mRT_iDiT_sub)],'r.')
h=gca;h.XTickLabel={'Conc','Inconc'};
ylim([0,1.5])

%% SUBFUNCTIONS
function imageID=GLshapes_imgID(shape_pair)
STIM=1:49;
STIM=reshape(STIM,[7,7]);
N=size(shape_pair,1);
imageID=zeros(N,1);
for i=1:N
imageID(i)=STIM(shape_pair(i,1),shape_pair(i,2));
end
end

function imgPairs=image_pairs(Target,Distractor)
imgPairs=[];
count=0;
for t=Target'
    for d=Distractor'
        count=count+1;
        imgPairs(count,:)=[t,d];
    end
end
end


function RT=fetch_RT(image_pairs, RTmatrix)
N=length(image_pairs);
Nsub=size(RTmatrix,3);
RT=zeros(N,Nsub);
for i=1:N
    T=image_pairs(i,1);
    D=image_pairs(i,2);
    RT(i,:)=RTmatrix(T,D,:);
end
end















