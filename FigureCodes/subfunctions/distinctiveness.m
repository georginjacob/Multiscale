function [DistG,DistL]=distinctiveness(stim,sD,d,impD)
% distinctiveness is defines as
% DistG(G1L1)=mean({d(G1L1,G2L1),d(G1L1,G3L1),....d(G1L1,G(N-1)L1)})
% DistL(G1L1)=mean({d(G1L1,G1L2),d(G1L1,G1L3),....d(G1L1,G1L(N-1))})
% DistO(G1L1): Overall global shape distinctiveness
N=length(stim);
DistG=zeros(N,1);DistL=zeros(N,1);DistO=zeros(N,1);
for ind =1:N
G=sD(ind,1);
L=sD(ind,2);
g1=impD(:,1);l1=impD(:,2);
g2=impD(:,3);l2=impD(:,4);
% global 
sel_index_G=((l1==L&l2==L&g1==G)|(l1==L&l2==L&g2==G)); % Keeping local constant and varying global
DistG(ind)=nanmean(d(sel_index_G));
% local
sel_index_L=((g1==G&g2==G&l1==L) |(g1==G&g2==G&l2==L));% Keeping global constant and varying local
DistL(ind)=nanmean(d(sel_index_L));
end