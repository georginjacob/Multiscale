# CONGRUENCE ANALYSIS

rm(list=ls())

Fulldata=read.csv("SAME_DIFFERENT_EXP.csv")

#*************************************************************************
##                            GSLS CONGRUENCE                            ##
#*************************************************************************
data=Fulldata[Fulldata$Type=="GSLS" & Fulldata$Outliers==0&Fulldata$RT>0.3&Fulldata$RT<2,]
#summary(data)
data$Congruence=NA
data[data$G1==data$L1,]$Congruence="Congruent"
data[data$G1!=data$L2,]$Congruence="Incongruent"
data_CI=data[!is.na(data$Congruence),]
data_CI$invRT=1/data_CI$RT
summary(data_CI)
#View(data_CI)

# Block-wise congruence effect
# Linear Mixed Model
library(car) # for Anova
library(lme4) # for lmer
library(lmerTest)

#factors
block_selected="global"
data_subset=data_CI[data_CI$Block==block_selected,]

data_subset$Block=factor(data_subset$Block)
data_subset$Congruence=factor(data_subset$Congruence)
data_subset$Subject=factor(data_subset$Subject)

# Linear Mixed Model
LMM_RT = lmer(RT ~ Congruence + (1|Subject),contrasts=list(Congruence='contr.sum'),data=data_subset,REML = FALSE)
anova(LMM_RT)

LMM_invRT = lmer(invRT ~ Congruence + (1|Subject),contrasts=list(Congruence='contr.sum'),data=data_subset,REML = FALSE)
anova(LMM_invRT)

# Linear Mixed Model

alternative_LMM_invRT = lmer(invRT ~ Congruence + (Congruence|Subject),contrasts=list(Congruence='contr.sum'),data=data_subset,REML = FALSE)
anova(alternative_LMM_invRT)

# Residual Analysis
library(MASS)
library(fitdistrplus)
library(ggplot2)

# RESIDUAL ANALYSIS 
RE_RT=residuals(LMM_RT)
fit_norm_RT<- fitdist(RE_RT, "norm",method="mle")
fig_A<-denscomp(list(fit_norm_RT),main="Distribution of LMM on RT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-1,1),
                breaks = 28,
                dempcol="blue")+
  geom_line(color="Red",size=1)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_B<-qqcomp(list(fit_norm_RT),main="QQ plot-RT model",plotstyle="ggplot",xlim=c(-1.25,1.25),ylim=c(-1.25,1.25),show.legend = FALSE)+
  geom_point(color="Red",size=1,shape=19)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())+
  theme(legend.position = "none")

#invRT
RE_invRT=residuals(LMM_invRT)
fit_norm_invRT<- fitdist(RE_invRT, "norm",method="mle")
fig_C<-denscomp(list(fit_norm_invRT),main="Distribution of LMM on invRT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-1,1), breaks = 40)+
  geom_line(color="Red",size=1)+
  theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_D<-qqcomp(list(fit_norm_invRT),main="QQ plot-inv RT model",plotstyle="ggplot",xlim=c(-1.25,1.25),ylim=c(-1.25,1.25),show.legend = FALSE)+
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
#####################


# # BLOCK and CONGRUENCE AS FACTORS
data_CI$Block=factor(data_CI$Block)
data_CI$Congruence=factor(data_CI$Congruence)
data_CI$Subject=factor(data_CI$Subject)

M_bc_RT = lmer(RT ~ Block*Congruence + (1|Subject),contrasts=list(Congruence='contr.sum',Block='contr.sum'),data=data_CI,REML = FALSE)
anova(M_bc_RT)

M_bc_invRT = lmer(invRT ~ Block*Congruence + (1|Subject),contrasts=list(Congruence='contr.sum',Block='contr.sum'),data=data_CI,REML = FALSE)
anova(M_bc_invRT)
# 
# summary(data_CI)
## Getting the size of congruence effect
library(plyr)
dat_summary_conc_temp=ddply(data_CI,c("Block","Congruence","ImagePair"),summarise, meanRT=mean(RT),std=sd(RT,na.rm = FALSE))
dat_summary_conc=ddply(dat_summary_conc_temp,c("Block","Congruence"),summarise, RT=mean(meanRT),std=sd(meanRT))

View(dat_summary_conc)


# RESIDUAL ANALYSIS 
RE_RT=residuals(M_bc_RT)
fit_norm_RT<- fitdist(RE_RT, "norm",method="mle")
fig_A<-denscomp(list(fit_norm_RT),main="Distribution of LMM on RT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-1,1),
                breaks = 28,
                dempcol="blue")+
  geom_line(color="Red",size=1)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_B<-qqcomp(list(fit_norm_RT),main="QQ plot-RT model",plotstyle="ggplot",xlim=c(-1.25,1.25),ylim=c(-1.25,1.25),show.legend = FALSE)+
  geom_point(color="Red",size=1,shape=19)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())+
  theme(legend.position = "none")

#invRT
RE_invRT=residuals(M_bc_invRT)
fit_norm_invRT<- fitdist(RE_invRT, "norm",method="mle")
fig_C<-denscomp(list(fit_norm_invRT),main="Distribution of LMM on invRT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-1,1), breaks = 40)+
  geom_line(color="Red",size=1)+
  theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_D<-qqcomp(list(fit_norm_invRT),main="QQ plot-inv RT model",plotstyle="ggplot",xlim=c(-1.25,1.25),ylim=c(-1.25,1.25),show.legend = FALSE)+
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
#####################










