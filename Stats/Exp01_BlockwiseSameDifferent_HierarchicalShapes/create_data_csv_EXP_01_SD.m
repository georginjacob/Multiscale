%% CREATE CSV FOR STATS in R
clc;clear all;close all;
load ../../FigureCodes/L2_SD;% Read SD exp data
%% Initialization 
GB.Subject=[];
GB.Block=[];
GB.Order=[];
GB.Type=[];
GB.ImagePair=[];
GB.Trial=[];
GB.TrialOrder=[];
GB.RT=[];
GB.Outliers=[];

LB.Subject=[];
LB.Block=[];
LB.Order=[];
LB.Type=[];
LB.ImagePair=[];
LB.Trial=[];
LB.TrialOrder=[];
LB.RT=[];
LB.Outliers=[];


S=size(L2_str.RT.global);
sub=cell2mat(L2_str.subj_id);sub=sub';
SUB=repmat(sub,[S(1),1,6]);

% subject
GB.Subject=SUB;
LB.Subject=SUB;

% Block order
Order=cell(S(1),S(2),6);
odd_sub=find(rem(sub,2)==1);
% odd subjects: global-local
Order(:,odd_sub,:)={'global-local'};
even_sub=find(rem(sub,2)==0);
% even subjects: local-global
Order(:,even_sub,:)={'local-global'};

GB.Order=Order;
LB.Order=Order;

% block
GB.Block=cell([S(1),S(2),6]);
GB.Block(:,:,:)={'global'};
LB.Block=cell([S(1),S(2),6]);
LB.Block(:,:,:)={'local'};

% Outlier
[GB.RT,GB.Outliers,GB.Trial,GB.TrialOrder]=find_outliers(L2_str.RT.global,L2_str.trialNumber.global);
[LB.RT,LB.Outliers,LB.Trial,LB.TrialOrder]=find_outliers(L2_str.RT.local,L2_str.trialNumber.local);

% Image Pairs
% global
gImgPairs=L2_str.imgpairs.global;
xx=position_finder(gImgPairs(:,1),gImgPairs(:,2),49);
GB.ImagePair=repmat(xx,[1,S(2),6]);
% local
lImgPairs=L2_str.imgpairs.local;
xx=position_finder(lImgPairs(:,1),lImgPairs(:,2),49);
LB.ImagePair=repmat(xx,[1,S(2),6]);
% Image1 & Image2
GB.Image1=repmat(L2_str.imgpairs.global(:,1),[1,S(2),6]);
GB.Image2=repmat(L2_str.imgpairs.global(:,2),[1,S(2),6]);

LB.Image1=repmat(L2_str.imgpairs.local(:,1),[1,S(2),6]);
LB.Image2=repmat(L2_str.imgpairs.local(:,2),[1,S(2),6]);

% Shape Details 
GB.G1=repmat(L2_str.trialDetails.global(:,2),[1,S(2),6]);
GB.L1=repmat(L2_str.trialDetails.global(:,3),[1,S(2),6]);
GB.G2=repmat(L2_str.trialDetails.global(:,4),[1,S(2),6]);
GB.L2=repmat(L2_str.trialDetails.global(:,5),[1,S(2),6]);

LB.G1=repmat(L2_str.trialDetails.local(:,2),[1,S(2),6]);
LB.L1=repmat(L2_str.trialDetails.local(:,3),[1,S(2),6]);
LB.G2=repmat(L2_str.trialDetails.local(:,4),[1,S(2),6]);
LB.L2=repmat(L2_str.trialDetails.local(:,5),[1,S(2),6]);

% Pair Details 
% global 
GB.Type=cell([S(1),S(2),6]);
G_gsls=find(GB.G1(:,1)==GB.G2(:,1) &GB.L1(:,1)==GB.L2(:,1));
G_gsld=find(GB.G1(:,1)==GB.G2(:,1) &GB.L1(:,1)~=GB.L2(:,1));
G_gdls=find(GB.G1(:,1)~=GB.G2(:,1) &GB.L1(:,1)==GB.L2(:,1));
G_gdld=find(GB.G1(:,1)~=GB.G2(:,1) &GB.L1(:,1)~=GB.L2(:,1));

% local 
LB.Type=cell([S(1),S(2),6]);
L_gsls=find(LB.G1(:,1)==LB.G2(:,1) &LB.L1(:,1)==LB.L2(:,1));
L_gsld=find(LB.G1(:,1)==LB.G2(:,1) &LB.L1(:,1)~=LB.L2(:,1));
L_gdls=find(LB.G1(:,1)~=LB.G2(:,1) &LB.L1(:,1)==LB.L2(:,1));
L_gdld=find(LB.G1(:,1)~=LB.G2(:,1) &LB.L1(:,1)~=LB.L2(:,1));


GB.Type(G_gsls,:,:)={'GSLS'};
GB.Type(G_gsld,:,:)={'GSLD'};
GB.Type(G_gdls,:,:)={'GDLS'};
GB.Type(G_gdld,:,:)={'GDLD'};

LB.Type(L_gsls,:,:)={'GSLS'};
LB.Type(L_gsld,:,:)={'GSLD'};
LB.Type(L_gdls,:,:)={'GDLS'};
LB.Type(L_gdld,:,:)={'GDLD'};

% Response
%GB
Gsame_response=find(L2_str.trialDetails.global(:,1)==0);
Gdiff_response=find(L2_str.trialDetails.global(:,1)==1);
GB.Response=cell(S(1),S(2),6);
GB.Response(Gsame_response,:,:)={'same'};
GB.Response(Gdiff_response,:,:)={'diff'};

%LB
Lsame_response=find(L2_str.trialDetails.global(:,1)==0);
Ldiff_response=find(L2_str.trialDetails.global(:,1)==1);
LB.Response=cell(S(1),S(2),6);
LB.Response(Lsame_response,:,:)={'same'};
LB.Response(Ldiff_response,:,:)={'diff'};

%% Deleting ROW
name=fieldnames(GB);
for i=1:length(name)
    xx=sprintf('GB.%s=[vec(GB.%s(1:147,:,1:2));vec(GB.%s(147+(1:49),:,:));vec(GB.%s(294+(1:294),:,1:2))];',name{i},name{i},name{i},name{i});
    eval(xx);
end
name=fieldnames(LB);
for i=1:length(name)
    xx=sprintf('LB.%s=[vec(LB.%s(1:147,:,1:2));vec(LB.%s(147+(1:49),:,:));vec(LB.%s(294+(1:294),:,1:2))];',name{i},name{i},name{i},name{i});
    eval(xx);
end

%% Making Table 
gg='Tg=table(';
ll='Tl=table(';
for i=1:length(name)
    if(i~=length(name))
        gg=[gg,sprintf('GB.%s,',name{i})];
        ll=[ll,sprintf('LB.%s,',name{i})];
    else
        gg=[gg,sprintf('GB.%s);',name{i})];
        ll=[ll,sprintf('LB.%s);',name{i})];
    end
end
eval(gg)
eval(ll)
Tg.Properties.VariableNames=name;
Tl.Properties.VariableNames=name;

TD=[Tg;Tl];
writetable(TD,'SAME_DIFFERENT_EXP.csv')
%%
function [RT,Outliers,Trial,TrialOrder]=find_outliers(RT,Trial)
% Changing RT
RT(:,:,3:6)=NaN;
RT(147+(1:49),:,3:4)=RT(147+49+(1:49),:,1:2); % copying 3rd and 4th Repeat 
RT(147+(1:49),:,5:6)=RT(147+49+49+(1:49),:,1:2); % copying 5th and 6th repeat
RT(147+49+(1:98),:,:)=NaN;

% Changing Trial Number
Trial(:,:,3:6)=NaN;
Trial(147+(1:49),:,3:4)=Trial(147+49+(1:49),:,1:2); % copying 3rd and 4th Repeat 
Trial(147+(1:49),:,5:6)=Trial(147+49+49+(1:49),:,1:2); % copying 5th and 6th repeat
Trial(147+49+(1:98),:,:)=NaN;

S=size(RT);

TrialOrder=zeros(S);
TrialOrder(1:147,:,3:6)=NaN; % first 147, GSLD pairs, has 2 reps
TrialOrder(295:end,:,3:6)=NaN; % Except GSLS pairs, all others have 2 reps 
TrialOrder(147+49+(1:98),:,:)=NaN; % Adjusted region

Outliers=zeros(S);
Outliers(1:147,:,3:6)=NaN; % first 147, GSLD pairs, has 2 reps
Outliers(295:end,:,3:6)=NaN; % Except GSLS pairs, all others have 2 reps 
Outliers(147+49+(1:98),:,:)=NaN; % Adjusted region

for i=1:S(1)
    for j=1:S(2)
        trial_number=squeeze(Trial(i,j,:));
        [~,INDEX]=sort(trial_number);
        INDEX(isnan(trial_number),1)=NaN;
        TrialOrder(i,j,:)=INDEX;
    end
end


for ind=1:length(RT)
    values=vec(RT(ind,:,:));
    xx= isoutlier(values,'median');
    xx=reshape(xx,16,6);
    Outliers(ind,xx)=1;
end
end
