% Exp03-Comparing Hierarchical Shapes with Interior Shapes
clc;clear all; close all;

% Reading the L2_str
load('L2_GLIE.mat') ;
RT=L2_str.RT.trial_wise; % All possible RT
RT_avg=nanmean(RT,3);
RT_avg_mean=mean(RT_avg,2);
img_pairs=L2_str.img_pairs;   % Reading all possible image pairs in the data

% Constants
Set_Num=4;% This is the number of sets in the experiment
StimuliPerSet=25;
Shape_Num=sqrt(StimuliPerSet);
Stimuli_Size=StimuliPerSet*Set_Num;
Image_Pair_Size=nchoosek(StimuliPerSet,2);
set_name={'IE(set1)','IE(set2)','GL(set1)','GL(set2)'};
%% % MDS plot
% Resizing the image to lower resolution
INPUT_IMAGES_v=L2_str.images;
for i=1:Stimuli_Size
    temp=INPUT_IMAGES_v(i);
    INPUT_IMAGES_v{i}=imresize((temp{1}),[100,100]);
end
Y=zeros(StimuliPerSet,2,Set_Num);
Z=zeros(StimuliPerSet,2,Set_Num);
for i=2:2:Set_Num
    figure;
    index_image_pair=Image_Pair_Size*(i-1)+(1:Image_Pair_Size);
    index_stimuli=StimuliPerSet*(i-1)+(1:StimuliPerSet);
    [c,p,Y(:,:,i)]=simplot((1./RT_avg_mean(index_image_pair)),INPUT_IMAGES_v(index_stimuli),0.05);
    if(i==1)
        Z(:,:,i)=Y(:,:,i);
    else
        Z(:,:,i)=Y(:,:,i);
        [d,Z(:,:,i),tr]=procrustes(Y(:,:,1),Y(:,:,i));
    end
end
index_set=reshape(1:Image_Pair_Size*Set_Num,Image_Pair_Size,Set_Num);
X=get_model_matrix(L2_str,Image_Pair_Size);
%% Model Prediction
plot_prop={'.k','.r'};
for SET_NUM =1:4
index_selected_set=index_set(:,SET_NUM);
dobs=(1./RT_avg_mean(index_selected_set,:));
Model_coeff(:,SET_NUM)=regress(dobs,X);
dpre=X*Model_coeff(:,SET_NUM);

if(SET_NUM==2 ||SET_NUM==4)
   figure(3);
   subplot(2,2,SET_NUM/2)
   corrplot(dpre,dobs,set_name{SET_NUM},1,plot_prop{SET_NUM/2}); 
   xlabel('Predicted Dissimilarity');
   ylabel('Observed Dissimilarity');
end
end
%% Code used to create figures for GL vs IE 
dobs_value=1./mean(RT_avg,2);
figure(3);
subplot(2,2,[3,4])
index_set2=index_set(:,2);
index_set4=index_set(:,4);
corrplot(dobs_value(index_set2),dobs_value(index_set4),'GL vs IE',1);
xlabel('dobs IE');ylabel('dobs Hierarchical');

%% panel G 
%  Coefficient mean
IE_SET2=Model_coeff(1:40,2);
IE_SET2_mean=mean(abs(reshape(IE_SET2,10,4)));
IE_SET2_sem=std(reshape(IE_SET2,10,4))/sqrt(10);
GL_SET4=Model_coeff(1:40,4);
GL_SET4_mean=mean(abs(reshape(GL_SET4,10,4)));
GL_SET4_sem=std(reshape(GL_SET4,10,4))/sqrt(10);

data_mean=[IE_SET2_mean;GL_SET4_mean];
data_sem=[IE_SET2_sem;GL_SET4_sem];

figure;
h=bar(data_mean', 'grouped');
hold on
Xpos=[(1:4)-0.15;(1:4)+0.15];
errorbar(Xpos',data_mean',data_sem','.')
h=gca;
h.XTickLabel={'Local','Global','Across','Within'};
legend('Interior Exterior','Hierarchical');
ylabel('Average Magnitude, s^{-1}')
title('Model Parameters Comparison');

%% panel H
% IE 
dataIE_mean=[];
dataIE_sem=[];
for i=1:2
    IE_SET=Model_coeff(1:40,i);
    IE_SET_mean=mean(abs(reshape(IE_SET,10,4)));
    IE_SET_sem=std(reshape(IE_SET,10,4))/sqrt(10);
    dataIE_mean=[dataIE_mean;IE_SET_mean];
    dataIE_sem=[dataIE_sem;IE_SET_sem];
end
figure
subplot(2,1,1)
bar(dataIE_mean');hold on;
Xpos=[(1:4)-0.1;(1:4)+0.1];
errorbar(Xpos,dataIE_mean,dataIE_sem)
axis([0,5,0,1.1])
h.XTickLabel={'Local','Global','Across','Within'};
ylabel('Average Magnitude, s^{-1}');
title('Interior Exterior (size-2 vs size-1');
% Hierarchical
data_GL_mean=[];
data_GL_sem=[];
for i=3:4
    GL_SET=Model_coeff(1:40,i);
    GL_SET_mean=mean(abs(reshape(GL_SET,10,4)));
    GL_SET_sem=std(reshape(GL_SET,10,4))/sqrt(10);
    data_GL_mean=[data_GL_mean;GL_SET_mean];
    data_GL_sem=[data_GL_sem;GL_SET_sem];
end
subplot(2,1,2)
bar(data_GL_mean');hold on;
Xpos=[(1:4)-0.1;(1:4)+0.1];
errorbar(Xpos, data_GL_mean,data_GL_sem)
axis([0,5,0,1.1])
h=gca;
h.XTickLabel={'Local','Global','Across','Within'};
ylabel('Average Magnitude, s^{-1}');
title('Hierarchical (size-2 vs size-1');


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




