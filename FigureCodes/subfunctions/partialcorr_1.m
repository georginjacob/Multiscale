function [coef,pval,ru,rl]=partialcorr_1(x,z,alpha)
% X is a N X P matrix with rows corresponding to observations, and columns corresponding to variable
% Z is Z an N-by-Q matrix, with rows corresponding to observations, and columns corresponding to Leftout variable
% alpha (optional) : Confidence limits, alpha=0.3173, one standard deviation (default) 
if(~exist('alpha','var'))
alpha=0.3173;
end
[n,d] = size(x);
z1 = [ones(n,1) z];
resid = x - z1*(z1 \ x);
dz = rank(z);tol = max(n,dz)*eps(class(x))*sqrt(sum(abs(x).^2,1));% this section is copied from standard matlab code partialcorr, |correction for precision errors when two are highly correlated|
resid(:,sqrt(sum(abs(resid).^2,1)) < tol) = 0;
[coef,pval,rl,ru] = corrcoef(resid,'alpha',alpha);
end