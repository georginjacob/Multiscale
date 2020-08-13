function [sumD,Gdist_vec,Ldist_vec]= compute_D_dist(D,Gdist,Ldist,ip,ipD)
% D     : Distinctiveness (49x1)
% Gdist : Global distance
% Ldist : Local  distance
% ip    : Image Pairs (Nx2)
% ipD   : Image Pair Details (Nx4: G1,L1,G2,L2)

N=length(ip);
sumD=zeros(N,1);
Gdist_vec=zeros(N,1);
Ldist_vec=zeros(N,1);
for ind =1:N
    g1=ipD(ind,1);l1=ipD(ind,2);
    g2=ipD(ind,3);l2=ipD(ind,4);
    ip1=ip(ind,1);
    ip2=ip(ind,2);
    sumD(ind,1)= (D(ip1)+D(ip2));
    if(~isempty(Gdist))
        if(g1~=g2)
            pos=position_finder(g1,g2,7);
            Gdist_vec(ind)=Gdist(pos);
        end
    end
    if(~isempty(Ldist))
        if(l1~=l2)
            pos=position_finder(l1,l2,7);
            Ldist_vec(ind)=Ldist(pos);
        end
    end
end
end

