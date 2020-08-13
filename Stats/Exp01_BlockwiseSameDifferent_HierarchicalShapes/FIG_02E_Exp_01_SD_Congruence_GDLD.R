# CONGRUENCE ANALYSIS : GDLD
rm(list=ls())

Fulldata=read.csv("SAME_DIFFERENT_EXP.csv")

# Linear Mixed Model
library(car) # for Anova
library(lme4) # for lmer
library(lmerTest)

data=Fulldata[Fulldata$Type=="GDLD"& Fulldata$Outliers==0 &Fulldata$RT>0.3&Fulldata$RT<2.0,]
data$invRT=1/(data$RT)

# congruence
summary(data)
data$Congruence=NA
data[data$G1==data$L1 & data$G2==data$L2,]$Congruence="Congruent"
data[data$G1==data$L2&data$G2==data$L1,]$Congruence="Incongruent"
data_CI=data[!is.na(data$Congruence),]
xx=data_CI[c("Block","RT")]


# factors
View(data_CI)

block_selected="local"
data_subset=data_CI[data_CI$Block==block_selected,]
#View(data_subset)

data_subset$ShapePair=NA

index=data_subset$Congruence=="Congruent"
data_subset[index,]$ShapePair=paste(data_subset[index,]$G1,"_",data_subset[index,]$G2)
index=data_subset$Congruence=="Incongruent"
data_subset[index,]$ShapePair=paste(data_subset[index,]$G2,"_",data_subset[index,]$G1)

data_subset$Subject=factor(data_subset$Subject)
data_subset$Congruence=factor(data_subset$Congruence)
data_subset$ShapePair=factor(data_subset$ShapePair)

# LMM Model
LMM_RT = lmer(RT ~ (Congruence*ShapePair) + (1|Subject),contrasts=list(Congruence='contr.sum',ShapePair='contr.sum'), data=data_subset,REML = FALSE)
anova(LMM_RT)


LMM_invRT = lmer(invRT ~ (Congruence*ShapePair) + (1|Subject),contrasts=list(Congruence='contr.sum',ShapePair='contr.sum'), data=data_subset,REML = FALSE)
anova(LMM_invRT)

# Alternative Model
alternative_LMM_RT = lmer(RT ~ (Congruence) + (Congruence|Subject)+(1|ShapePair),contrasts=list(Congruence='contr.sum'), data=data_subset,REML = FALSE)
anova(alternative_LMM_RT)

alternative_LMM_invRT = lmer(invRT ~ (Congruence) + (1|Subject)+(Congruence|ShapePair),contrasts=list(Congruence='contr.sum'), data=data_subset,REML = FALSE)
anova(alternative_LMM_invRT)

# Post-Hoc analysis
library(plyr)
data_subset_summary<-ddply(data_subset, .(Congruence,ShapePair), summarize,RT = mean(RT))
data_subset_summary_wide<-reshape(data_subset_summary,idvar = "ShapePair",timevar="Congruence",v.names="RT", direction="wide", sep="_")
img_pair_CONC_count=data_subset_summary_wide$RT_Congruent <data_subset_summary_wide$RT_Incongruent 
print("Number of Image Pairs showing Congruence")
summary(img_pair_CONC_count)


# Residual Analysis
library(MASS)
library(fitdistrplus)
library(ggplot2)

# RESIDUAL ANALYSIS FUNCTION 
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

# Block effect
index=data_CI$Congruence=="Congruent"
data_CI$ShapePair=NA
data_CI[index,]$ShapePair=paste(data_CI[index,]$G1,"_",data_CI[index,]$G2)
index=data_CI$Congruence=="Incongruent"
data_CI[index,]$ShapePair=paste(data_CI[index,]$G2,"_",data_CI[index,]$G1)
data_CI$ShapePair=factor(data_CI$ShapePair)
summary(data_CI)

# factors
data_CI$Subject=factor(data_CI$Subject)
data_CI$Congruence=factor(data_CI$Congruence)
data_CI$ShapePair=factor(data_CI$ShapePair)
View(data_CI)

## Getting the size of congruence effect
library(plyr)
dat_summary_conc_temp=ddply(data_CI,.(Block,ShapePair,Congruence),summarize, RT=mean(RT))
dat_summary_conc=ddply(dat_summary_conc_temp,c("Block","Congruence"),summarize, meanRT=mean(RT),stdRT=sd(RT))
dat_summary_conc


M_bcs_RT = lmer(RT ~ (Block*Congruence*ShapePair) + (1|Subject),contrasts=list(Block='contr.sum',Congruence='contr.sum',ShapePair='contr.sum'), data=data_CI,REML=FALSE)
anova(M_bcs_RT)

M_bcs_invRT = lmer(invRT ~ (Block*Congruence*ShapePair) + (1|Subject),contrasts=list(Block='contr.sum',Congruence='contr.sum',ShapePair='contr.sum'), data=data_CI,REML=FALSE)
anova(M_bcs_invRT)


# RESIDUAL ANALYSIS FUNCTION 
RE_RT=residuals(M_bcs_RT)
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
RE_invRT=residuals(M_bcs_invRT)
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
# 
# #*************************************************************************
# ##                            GDLD CONGRUENCE                            ##
# #*************************************************************************
data=Fulldata[Fulldata$Type=="GDLD",]
summary(data)
data$Congruence=NA
data[data$G1==data$L1 & data$G2==data$L2,]$Congruence="Congruent"
data[data$G1==data$L2&data$G2==data$L1,]$Congruence="Incongruent"
data_CI=data[!is.na(data$Congruence),]

data_CI$Congruence=factor(data_CI$Congruence)
summary(data_CI)

library(plyr)
meandata=ddply(data_CI, .(Subject,Block,ImagePair,Congruence), summarize,RT = mean(RT))
ddply(meandata, ~ Block*Congruence, summarise, RT.mean=mean(RT), RT.sd=sd(RT))


# GLOBAL/LOCAL
block_selected="global"

data_subset=data_CI[data_CI$Block==block_selected,]


data_subset$invRT=1/(data_subset$RT)
# shape Pair
data_subset$shapepair=NA

index=data_subset$G1<data_subset$G2
data_subset[index,]$shapepair=paste(data_subset[index,]$G1,"_",data_subset[index,]$G2)


index=data_subset$G1>data_subset$G2
data_subset[index,]$shapepair=paste(data_subset[index,]$G2,"_",data_subset[index,]$G1)


# factors
data_subset$shapepair=factor(data_subset$shapepair)
data_subset$Congruence=factor(data_subset$Congruence)
data_subset$Subject=factor(data_subset$Subject)
data_subset$Trial=factor(data_subset$Trial)

#RT
fit_na=aov(RT~Congruence*shapepair*Subject,contrasts=list(Congruence='contr.sum', shapepair ='contr.sum', Subject = 'contr.sum'),data=data_subset)
anova(fit_na)

#invRT
fit_inv_na=aov(invRT~Congruence*shapepair*Subject,contrasts=list(Congruence='contr.sum', shapepair ='contr.sum',Subject = 'contr.sum'),data_subset)
anova(fit_inv_na)


# Repeated Measures Anova
library(car)
library(plyr)


mean_data_subset=ddply(data_subset, .(Subject,shapepair, Congruence), summarize,RT = mean(RT),invRT=1/(mean(RT)))
fit_ra <- aov(RT ~ Congruence*shapepair+Error(Subject/(Congruence*shapepair)),contrasts=list(Congruence='contr.sum', shapepair ='contr.sum'), data=mean_data_subset)
summary(fit_ra)


fit_RT_ra <- aov(RT ~ Congruence*shapepair+Error(Subject/(Congruence*shapepair)),contrasts=list(Congruence='contr.sum', shapepair ='contr.sum'), data=mean_data_subset)
summary(fit_RT_ra)


fit_inv_ra <- aov(invRT ~ Congruence*shapepair+Error(Subject/(Congruence*shapepair)),contrasts=list(Congruence='contr.sum', shapepair ='contr.sum'), data=mean_data_subset)
summary(fit_inv_ra)
