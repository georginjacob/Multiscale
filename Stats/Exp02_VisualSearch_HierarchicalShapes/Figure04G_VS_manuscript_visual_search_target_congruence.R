rm(list = ls())
DATA=read.csv(file = "VS_target_congruence.csv")
summary(DATA)

DATA$Subject=factor(DATA$Subject)
DATA$Target=factor(DATA$Target)
DATA$ShapePairs=factor(DATA$ShapePairs)

DATA$invmeanRT=1/DATA$meanRT

library(lme4)
library(lmerTest)

lmm_RT=lmer(meanRT~Target*ShapePairs+(1|Subject),data=DATA, REML = FALSE)
anova(lmm_RT)

lmm_invRT=lmer(invmeanRT~Target*ShapePairs+(1|Subject),data=DATA, REML = FALSE)
anova(lmm_invRT)


#################### RESIDUALS ##################################
library(MASS)
library(fitdistrplus)
library(ggplot2)

RE_RT=residuals(lmm_RT)
fit_norm_RT<- fitdist(RE_RT, "norm",method="mle")
fig_A<-denscomp(list(fit_norm_RT),main="Distribution of LMM on RT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-0.75,0.75),
                breaks = 10,
                dempcol="blue")+
  geom_line(color="Red",size=1)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_B<-qqcomp(list(fit_norm_RT),main="QQ plot-RT model",plotstyle="ggplot",xlim=c(-0.75,0.75),ylim=c(-0.75,0.75),show.legend = FALSE)+
  geom_point(color="Red",size=1,shape=19)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())+
  theme(legend.position = "none")

#invRT
RE_invRT=residuals(lmm_invRT)
fit_norm_invRT<- fitdist(RE_invRT, "norm",method="mle")
fig_C<-denscomp(list(fit_norm_invRT),main="Distribution of LMM on invRT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-0.75,0.75), breaks = 10)+
  geom_line(color="Red",size=1)+
  theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_D<-qqcomp(list(fit_norm_invRT),main="QQ plot-inv RT model",plotstyle="ggplot",xlim=c(-0.75,0.75),ylim=c(-0.75,0.75),show.legend = FALSE)+
  geom_point(color="Red",size=1, shape=19)+
  theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())+
  theme(legend.position = "none")

library("ggpubr")
ggarrange(fig_A,fig_B,fig_C,fig_D,labels=c("A","B","C","D"))


##################### normality test
normality_RT=ks.test(RE_RT,"pnorm",mean=mean(RE_RT),sd=sd(RE_RT))
print(normality_RT)

normality_invRT=ks.test(RE_invRT,"pnorm",mean=mean(RE_invRT),sd=sd(RE_invRT))
print(normality_invRT)
