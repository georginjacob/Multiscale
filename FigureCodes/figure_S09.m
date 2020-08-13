% Analysis code- Experiment 05
% Effect of Grouping on Interior Exterior Stimuli
clc;clear all;close all;
load L2_IEgrouping.mat; % Loading the data

%% Constants
Set_Num=2;% This is the number of sets in the experiment
StimuliPerSet=25;
Shape_Num=sqrt(StimuliPerSet);
Stimuli_Size=StimuliPerSet*Set_Num;
Image_Pair_Size=nchoosek(StimuliPerSet,2);
%% Average RT
RT=L2_str.RT.trial_wise; % All possible RT
RT_avg=nanmean(RT,3);
RT_avg_mean=mean(RT_avg,2);
dobs_value=1./RT_avg_mean;
img_pairs=L2_str.img_pairs;   % Reading all possible image pairs in the data
%% % MDS plot
% Resizing the image to lower resolution
INPUT_IMAGES_v=L2_str.images;
for i=1:Stimuli_Size
    temp=INPUT_IMAGES_v(i);
    INPUT_IMAGES_v{i}=rgb2gray(imresize((temp{1}),[100,100]));
end
figure
simplot((1./RT_avg_mean(1:Image_Pair_Size)),INPUT_IMAGES_v(1:StimuliPerSet),0.07);
axis equal

%% Modelling
index_set=reshape(1:Image_Pair_Size*Set_Num,Image_Pair_Size,Set_Num);
X=get_model_matrix(L2_str,Image_Pair_Size);
plot_prop={'.k','.r'};
for SET_NUM =1:Set_Num
index_selected_set=index_set(:,SET_NUM);
dobs=(1./RT_avg_mean(index_selected_set,:));
Model_coeff(:,SET_NUM)=regress(dobs,X);
dpre=X*Model_coeff(:,SET_NUM);
xx=corrcoef(dobs,dpre);model_correlation(SET_NUM)=xx(1,2);
end
%% Average Model Coefficient
mean_coeff=zeros(4,Set_Num);
sem_coeff=zeros(4,Set_Num);
for i=1:4
    for j=1:Set_Num
        mean_coeff(i,j)=mean(abs(Model_coeff(10*(i-1)+(1:10),j)));
        sem_coeff(i,j)=std(abs(Model_coeff(10*(i-1)+(1:10),j)))/sqrt(10);
    end
end
figure 
bar(mean_coeff)
hold on
Xpos=[(1:4)-0.15;(1:4)+0.15];
errorbar(Xpos, mean_coeff',sem_coeff','.')
axis([0,5,0,1.1])
h=gca;
h.XTickLabel={'Local','Global','Across','Within'};
ylabel('Average Magnitude, s^{-1}');
title('Comparing model coefficients across sets');
legend({'set-1','set-2'})
% figure;
% bar(model_correlation);
% xlabel('Sets');
% ylabel('Model Correlations');
%% Sub Functions
function X=get_model_matrix(L2_str,Image_Pair_Size)
Shape_Num=5;
Li=1:10;
Gi=11:20;
Ci=21:30;
Ii=31:40;
Di=41;
X=zeros(Image_Pair_Size,length(Li)+length(Gi)+length(Ci)+length(Ii)+1);
%%%%%%%%%%%%%%%%%%%%%% Change
X(:,end)=1;
Local_offset_G=length(Li);%10
Local_offset_GLB=Local_offset_G+length(Gi);%20
Local_offset_GLW=Local_offset_GLB +length(Ci);%30
for i=1:Image_Pair_Size
    % Change these numbers according to definition of Image Pair
    % details
    g1=L2_str.Image_Pair_Details(i,3);
    g2=L2_str.Image_Pair_Details(i,8);
    l1=L2_str.Image_Pair_Details(i,2);
    l2=L2_str.Image_Pair_Details(i,7);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (l1~=l2) %LCBs
        L_index=position_finder( l1, l2,Shape_Num );
        X(i,L_index)=1;
    end
    
    if(g1~=g2)   %GCB
        G_index=position_finder( g1, g2,Shape_Num );
        X(i,Local_offset_G+G_index)=1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (g1~=l2) %GLCB
        GL_index1=position_finder( g1, l2,Shape_Num );
        X(i,Local_offset_GLB+GL_index1)=X(i,Local_offset_GLB+GL_index1)+1;
    end
    
    if(l1~=g2)  %GLCB
        GL_index2=position_finder( l1, g2,Shape_Num );
        X(i,Local_offset_GLB+GL_index2)=X(i,Local_offset_GLB+GL_index2)+1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(l1~=g1)  %GLWB
        GL_index3=position_finder( l1, g1,Shape_Num );
        X(i,Local_offset_GLW+GL_index3)=X(i,Local_offset_GLW+GL_index3)+1;
    end
    
    if(l2~=g2)  %GLWB
        GL_index4=position_finder( l2, g2,Shape_Num );
        X(i,Local_offset_GLW+GL_index4)=X(i,Local_offset_GLW+GL_index4)+1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
end