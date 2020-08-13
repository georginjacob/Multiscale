function[coeff,preRT,X,RHO]=FitSD_combined(obsRT,estDist,ip,ipD,flag)
% lat modified : 16-05-2018
% This is a generalized model
% Model Terms : GD(7), LD(7), Gdist(21),Ldist(21)
% Parameters
% obsRT   : Observed Reaction Times
% estDist : Estimated Distinctivenes, expecting a 49x1 term.
% ipD     : Image Pair Details
% flag    : (GS:11,GD:12,LS:21,LD:22)
NS=7; % number of different shapes
Num_D=2; % number of distinctiveness terms
Num_d=nchoosek(NS,2);
N=length(ipD);
XF=zeros(N,Num_D+Num_d*2);
for ind=1:N
    g1=ipD(ind,1);l1=ipD(ind,2);
    g2=ipD(ind,3);l2=ipD(ind,4);
    ip1=ip(ind,1);
    ip2=ip(ind,2);
    %DISTINCTIVENESS
    % global
    XF(ind,1)= (estDist(ip1,1)+estDist(ip2,1));
    % local
    XF(ind,2)= (estDist(ip1,2)+estDist(ip2,2));
    % DISTANCE
    if (flag==11||flag==21)
        if (g1~=g2) % global
            pos=position_finder(g1,g2,7);
            XF(ind,Num_D+pos)=1;
        end
        if (l1~=l2) % Local
            pos=position_finder(l1,l2,7);
            XF(ind,Num_D+Num_d+pos)=1;
        end
    elseif(flag==12||flag==22)
        if (g1~=g2) % global
            pos=position_finder(g1,g2,7);
            XF(ind,Num_D+pos)=-1;
        end
        if (l1~=l2) % Local
            pos=position_finder(l1,l2,7);
            XF(ind,Num_D+Num_d+pos)=-1;
        end
    end
end
% Selection of terms according to block and response type
DG=1;DL=2;
gdist=Num_D+(1:Num_d);
ldist=Num_D+Num_d+(1:Num_d);

switch(flag)
    case 11 % GS
        X=XF(:,[DG,DL,ldist]);
    case 12 % GD
        X=XF(:,[DG,DL,gdist,ldist]);
    case 21 % LS
        X=XF(:,[DG,DL,gdist]);
    case 22 % LD
        X=XF(:,[DG,DL,gdist,ldist]);
end
coeff= regress(obsRT,X);
preRT=X*coeff;
end
