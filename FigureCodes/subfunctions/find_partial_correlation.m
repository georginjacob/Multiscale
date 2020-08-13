function [RHO] = find_partial_correlation(obsRT,DG,DL,Gdist,Ldist,ip,ipD,flag)
% This code calculate the partial correlations
% obsRT : observed Reaction Time (Nx1)
% DG     : Global Distinctiveness (49x1)
% DL     : Local Distinctiveness (49x1)
% Gdist : Global distance
% Ldist : Local  distance
% ip    : Image Pairs (Nx2)
% ipD   : Image Pair Details (Nx4: G1,L1,G2,L2)
% flag  : Flag to select the kind of analysis

% OUTPUT
% RHO   : Partial Correlations (4 x 4, (4 types of relations) x (correlations, p-value, lower limit, upper limit) 

% init
N=length(obsRT);
sumDG=zeros(N,1);
sumDL=zeros(N,1);
Gsumdist=zeros(N,1);
Lsumdist=zeros(N,1);
for ind =1:N
    g1=ipD(ind,1);l1=ipD(ind,2);
    g2=ipD(ind,3);l2=ipD(ind,4);
    ip1=ip(ind,1);
    ip2=ip(ind,2);
    sumDG(ind,1)= (DG(ip1)+DG(ip2));
    sumDL(ind,1)= (DL(ip1)+DL(ip2));
    if(g1~=g2)
        pos=position_finder(g1,g2,7);
        Gsumdist(ind)=Gdist(pos);
    end
    if(l1~=l2)
        pos=position_finder(l1,l2,7);
        Lsumdist(ind)=Ldist(pos);
    end
end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    switch(flag)
        case 11 % GS : DG,ldist,wdist
            % partial correlation
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,sumDG],[sumDL,Lsumdist]);RHO(1,1)=tempR(2);RHO(1,2)=tempP(2);RHO(1,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,sumDL],[sumDG,Lsumdist]);RHO(2,1)=tempR(2);RHO(2,2)=tempP(2);RHO(2,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,Lsumdist],[sumDG,sumDL]);RHO(4,1)=tempR(2);RHO(4,2)=tempP(2);RHO(4,3:4)=[tempL(2),tempU(2)];
        case 12 % GD
            % partial correlation
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,sumDG],[sumDL,Gsumdist,Lsumdist]);RHO(1,1)=tempR(2);RHO(1,2)=tempP(2);RHO(1,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,sumDL],[sumDG,Gsumdist,Lsumdist]);RHO(2,1)=tempR(2);RHO(2,2)=tempP(2);RHO(2,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]=partialcorr_1([obsRT,Gsumdist],[sumDG,sumDL,Lsumdist]);RHO(3,1)=tempR(2);RHO(3,2)=tempP(2);RHO(3,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,Lsumdist],[sumDG,sumDL,Gsumdist]);RHO(4,1)=tempR(2);RHO(4,2)=tempP(2);RHO(4,3:4)=[tempL(2),tempU(2)];
                       
        case 21 % LS : DL,lgist,wdist
            % partial correlation
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,sumDG],[sumDL,Gsumdist]);RHO(1,1)=tempR(2);RHO(1,2)=tempP(2);RHO(1,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,sumDL],[sumDG,Gsumdist]);RHO(2,1)=tempR(2);RHO(2,2)=tempP(2);RHO(2,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,Gsumdist],[sumDG,sumDL]);RHO(3,1)=tempR(2);RHO(3,2)=tempP(2);RHO(3,3:4)=[tempL(2),tempU(2)];
            
        case 22 % LD
            % partial correlation
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,sumDG],[sumDL,Gsumdist,Lsumdist]);RHO(1,1)=tempR(2);RHO(1,2)=tempP(2);RHO(1,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,sumDL],[sumDG,Gsumdist,Lsumdist]);RHO(2,1)=tempR(2);RHO(2,2)=tempP(2);RHO(2,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]=partialcorr_1([obsRT,Gsumdist],[sumDG,sumDL,Lsumdist]);RHO(3,1)=tempR(2);RHO(3,2)=tempP(2);RHO(3,3:4)=[tempL(2),tempU(2)];
            [tempR,tempP,tempU,tempL]= partialcorr_1([obsRT,Lsumdist],[sumDG,sumDL,Gsumdist]);RHO(4,1)=tempR(2);RHO(4,2)=tempP(2);RHO(4,3:4)=[tempL(2),tempU(2)];
    end


end

