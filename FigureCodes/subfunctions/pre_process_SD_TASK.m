function [same,diff,gmeanRT,lmeanRT,GimagePairDetails,LimagePairDetails,GimagePairs,LimagePairs,consistency_table_RT,gRtTrialwise_sub,lRtTrialwise_sub,consistency_table_1_RT,gRtTrialwise,lRtTrialwise]=pre_process_SD_TASK(L2_str)
% Apply outlier function and get trialwise data
clear q

RT = L2_str.RT.global;
% SECTION-1
%******************
RT(:,:,3:6)=NaN;RT(147+(1:49),:,3:4)=RT(147+49+(1:49),:,1:2);RT(147+(1:49),:,5:6)=RT(147+49+49+(1:49),:,1:2);RT(147+49+(1:98),:,:)=NaN;
for ind=1:length(RT)
    values=vec(RT(ind,:,:));temp= isoutlier(values,'median');q(ind,:)=double(temp); % finding the outliers
    temp_nan=isnan(values);% finding the NaNs
    q(ind,temp_nan)=NaN; % retaining the NaNs in the count matrix q
    RT(ind,temp)=NaN; % replacing the outliers by NaNs
end
%*****************
gRtTrialwise=RT;fracg = length(find(q(:)==1))/length(find(~isnan(q)));
RT = L2_str.RT.local;
%****************** repeated section-1
RT(:,:,3:6)=NaN;RT(147+(1:49),:,3:4)=RT(147+49+(1:49),:,1:2);RT(147+(1:49),:,5:6)=RT(147+49+49+(1:49),:,1:2);RT(147+49+(1:98),:,:)=NaN;
for ind=1:length(RT)
    values=vec(RT(ind,:,:));temp= isoutlier(values,'median');q(ind,:)=double(temp); % finding the outliers
    temp_nan=isnan(values);% finding the NaNs
    q(ind,temp_nan)=NaN; % retaining the NaNs in the count matrix q
    RT(ind,temp)=NaN; % replacing the outliers by NaNs
end
%*****************
lRtTrialwise=RT; fracl = length(find(q(:)==1))/length(find(~isnan(q)));

%%
clear RT values temp ind
 fprintf('\n Fraction of outliers removed GB= %.2f, LB= %.2f \n',fracg,fracl)

% subjectwise-data
gRtTrialwise_sub=nanmean(gRtTrialwise,3);
lRtTrialwise_sub=nanmean(lRtTrialwise,3);

GimagePairs=L2_str.imgpairs.global;
LimagePairs=L2_str.imgpairs.local;
% Image Pair details  : Order [S=0/D=1, G1={1,7},L1={1,7},G2={1,7},L2={1,7}
GimagePairDetails=L2_str.trialDetails.global;
LimagePairDetails=L2_str.trialDetails.local;

images=L2_str.images;
SubjId=L2_str.subj_id;
Nsub=length(L2_str.subj_name);
Nreps=2;

% image pairs based on saved data
same.global.GsameLdiff=find(GimagePairDetails(:,1)==0 & GimagePairDetails(:,2)==GimagePairDetails(:,4) & GimagePairDetails(:,3)~=GimagePairDetails(:,5));
same.global.GsameLsame=find(GimagePairDetails(:,1)==0 & GimagePairDetails(:,2)==GimagePairDetails(:,4) & GimagePairDetails(:,3)==GimagePairDetails(:,5));% repeats 49*3
diff.global.GdiffLsame=find(GimagePairDetails(:,1)==1 & GimagePairDetails(:,2)~=GimagePairDetails(:,4) & GimagePairDetails(:,3)==GimagePairDetails(:,5));
diff.global.GdiffLdiff=find(GimagePairDetails(:,1)==1 & GimagePairDetails(:,2)~=GimagePairDetails(:,4) & GimagePairDetails(:,3)~=GimagePairDetails(:,5));

same.local.GdiffLsame=find(LimagePairDetails(:,1)==0 & LimagePairDetails(:,2)~=LimagePairDetails(:,4) & LimagePairDetails(:,3)==LimagePairDetails(:,5));
same.local.GsameLsame=find(LimagePairDetails(:,1)==0 & LimagePairDetails(:,2)==LimagePairDetails(:,4) & LimagePairDetails(:,3)==LimagePairDetails(:,5));% repeats 49*3
diff.local.GsameLdiff=find(LimagePairDetails(:,1)==1 & LimagePairDetails(:,2)==LimagePairDetails(:,4) & LimagePairDetails(:,3)~=LimagePairDetails(:,5));
diff.local.GdiffLdiff =find(LimagePairDetails(:,1)==1 & LimagePairDetails(:,2)~=LimagePairDetails(:,4) & LimagePairDetails(:,3)~=LimagePairDetails(:,5));
%% rearranging the pairdetails
GimagePairDetails(same.global.GsameLsame(49+(1:98)),:)=NaN; % deleting the Imagepairs of 98 pairs
same.global.GsameLsame(49+(1:98))=[]; % deleting the
% local block
LimagePairDetails(same.local.GsameLsame(49+(1:98)),:)=NaN;
same.local.GsameLsame(49+(1:98))=[];
%% consistency check
consistency_array_RT=zeros(6,5);
consistency_array_1_RT=zeros(6,5);
for ind=1:6
clear sel_index sel_RT_sub
    switch(ind)
        case 1 % global same
            sel_index=[same.global.GsameLdiff;same.global.GsameLsame];
            sel_RT_sub=gRtTrialwise_sub(sel_index,:);
        case 2 % global diff
            sel_index=[diff.global.GdiffLsame;diff.global.GdiffLdiff];
            sel_RT_sub=gRtTrialwise_sub(sel_index,:);
        case 3 % local same 
            sel_index=[same.local.GdiffLsame;same.local.GsameLsame];
            sel_RT_sub=lRtTrialwise_sub(sel_index,:);
        case 4 % local diff
            sel_index=[diff.local.GsameLdiff;diff.local.GdiffLdiff];
            sel_RT_sub=lRtTrialwise_sub(sel_index,:);
        case 5 % GSLD: S response
            sel_index=[same.global.GsameLdiff];
            sel_RT_sub=gRtTrialwise_sub(sel_index,:);
        case 6 % GDLS: S response
            sel_index=[same.local.GdiffLsame];
            sel_RT_sub=lRtTrialwise_sub(sel_index,:);
            
    end
    % RT
    [cavg,pavg,pmax,~,ci]=splithalfcorr(sel_RT_sub');
    cci=spearmanbrowncorrection(ci,2);% corrected 
    consistency_array_RT(ind,:)=[spearmanbrowncorrection(cavg,2),std(cci),cavg,pavg,pmax];
    % 1/RT
      [cavg,pavg,pmax,ci]=splithalfcorrd(sel_RT_sub');
      cci=spearmanbrowncorrection(ci,2);% corrected 
     consistency_array_1_RT(ind,:)=[spearmanbrowncorrection(cavg,2),std(cci),cavg,pavg,pmax];  
    
end
fprintf('\n Consistency RT \n');
consistency_table_RT=array2table(consistency_array_RT,'VariableNames',{'correct_split_half','std_corrected_split_half','split_half','pavg','pmax'},'RowNames',{'GS','GD','LS','LD','GSLD-Same Response ','GDLS-Same Response'});
disp(consistency_table_RT);
fprintf('\n Consistency 1/RT \n');
consistency_table_1_RT=array2table(consistency_array_1_RT,'VariableNames',{'correct_split_half','std_corrected_split_half','split_half','pavg','pmax'},'RowNames',{'GS','GD','LS','LD','GSLD-Same Response ','GDLS-Same Response'});
disp(consistency_table_1_RT);

gmeanRT=nanmean(gRtTrialwise_sub,2);
lmeanRT=nanmean(lRtTrialwise_sub,2);
end