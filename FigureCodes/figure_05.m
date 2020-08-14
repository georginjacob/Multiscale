% Visual Search part-sum model
clc;clear all;close all;
load L2_VSmain.mat
% Images
images=L2_str.images;

% mean RT
RT_trialwise=L2_str.RT.trial_wise;
RT_avg=nanmean(RT_trialwise,[2,3]);

% Baton Model
dobs=1./RT_avg;
img_pairs=L2_str.img_pairs;

Li=1:21;Gi=22:42;Ci=43:63;Ii=64:84;Di=85;
X=zeros(size(img_pairs,1),length(Li)+length(Gi)+length(Ci)+length(Ii)+1);X(:,end)=1;
Local_offset_G=length(Li);%21
Local_offset_GLB=Local_offset_G+length(Gi);%42
Local_offset_GLW=Local_offset_GLB + 21;%63
Local_offset_CON=Local_offset_GLW+21;%84

Shape_Num=7;
for i=1:size(img_pairs,1)
    g1=L2_str.Image_Pair_Details(i,1);
    l1=L2_str.Image_Pair_Details(i,2);
    g2=L2_str.Image_Pair_Details(i,3);
    l2=L2_str.Image_Pair_Details(i,4);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (l1~=l2) %LCB
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
end

Coeff=regress(dobs,X);
dpre=X*Coeff;
%%
figure;
corrplot(dpre,dobs,[],1);
xlabel('Predicted dissimilarity, s^{-1}');
ylabel('Observed dissimilarity, s^{-1}');

%% parameter Correlation
figure;
subplot 131
corrplot(Coeff(Gi),Coeff(Li),[],[],'r.');
axis([0,1,-0.3,0.6])
xlabel('Large Scale');ylabel('Small Scale')

subplot 132
corrplot(Coeff(Gi),Coeff(Ci),[],1,'g.');
axis([0,1,-0.3,0.6])
xlabel('Large Scale');ylabel('Cross Scale Across')

subplot 133
corrplot(Coeff(Gi),Coeff(Ii),[],1,'b.');
axis([0,1,-0.3,0.6])
xlabel('Large Scale');ylabel('Cross Scale Within')
%% Global Shape Dissimilarity
% Dummy Shapes 
N_Shapes=7;Shapes={};
for i=0:N_Shapes-1
    file_name=['./figure5d/L',num2str(i),'.jpg'];
    Shapes{i+1}=imresize(rgb2gray(imread(file_name)),[700,700]);
end
figure;
simplot(Coeff(Gi),Shapes,0.07);