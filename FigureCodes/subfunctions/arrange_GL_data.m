function [GL_gRT,GL_lRT,GL_rt,GL_img_pair_details,GL_gPC,GL_lPC]= arrange_GL_data(L2_str_GL,GimagePairDetails,LimagePairDetails)
% This code is written to arrange VS data according to the arrangement in
% samde different task
GL_img_pair_details=L2_str_GL.Image_Pair_Details;
GL_img_pairs=L2_str_GL.img_pairs;
GL_rtTrialwise=L2_str_GL.RT.trial_wise;
GL_rt_Sub=nanmean(GL_rtTrialwise,3);
GL_rt=nanmean(GL_rt_Sub,2);
GL_images=L2_str_GL.images;
GL_PC=L2_str_GL.PC.image_pairs;
for ind=1:49
    GL_images{ind}=imresize(GL_images{ind},[100,100]);
end
% extracting data from visual search and arranging in the same order as
% that of same-different task
GL_g1=GL_img_pair_details(:,1);GL_l1=GL_img_pair_details(:,2);
GL_g2=GL_img_pair_details(:,3);GL_l2=GL_img_pair_details(:,4);
%global block
GL_gRT=nan(length(GimagePairDetails),size(GL_rt_Sub,2));
GL_gPC=nan(length(GimagePairDetails),size(GL_PC,2));
for ind=1:length(GimagePairDetails)
    SD=GimagePairDetails(ind,1);
    G1=GimagePairDetails(ind,2);
    L1=GimagePairDetails(ind,3);
    G2=GimagePairDetails(ind,4);
    L2=GimagePairDetails(ind,5);
    if((G1==G2 && L1==L2 || isnan(G1) ))% removing nans and identiacal image pairs
    else
        GL_gRT(ind,:)= GL_rt_Sub(find(GL_g1==G1 & GL_l1==L1 &GL_g2==G2 & GL_l2==L2),:);
        GL_gPC(ind,:)=GL_PC(find(GL_g1==G1 & GL_l1==L1 &GL_g2==G2 & GL_l2==L2),:);
    end
end
% local block
GL_lRT=nan(length(LimagePairDetails),size(GL_rt_Sub,2));
GL_lPC=nan(length(LimagePairDetails),size(GL_PC,2));
for ind=1:length(LimagePairDetails)
    SD=LimagePairDetails(ind,1);
    G1=LimagePairDetails(ind,2);
    L1=LimagePairDetails(ind,3);
    G2=LimagePairDetails(ind,4);
    L2=LimagePairDetails(ind,5);
    if((G1==G2 && L1==L2 || isnan(G1) ))% removing nans and identiacal image pairs
    else
        GL_lRT(ind,:)= GL_rt_Sub(find(GL_g1==G1 & GL_l1==L1 &GL_g2==G2 & GL_l2==L2),:);
        GL_lPC(ind,:)=GL_PC(find(GL_g1==G1 & GL_l1==L1 &GL_g2==G2 & GL_l2==L2),:);
    end
end

end