rm(list=ls())

Fulldata=read.csv("SAME_DIFFERENT_EXP.csv")
#summary(Fulldata) # Check the data

# Selecting GSLSData from the full data 
data_gsls=Fulldata[Fulldata$Type=="GSLS"& Fulldata$Outliers==0 &Fulldata$RT>0.3&Fulldata$RT<2.0,] # Removing fast RT's (RT< 300 ms) and very slow RTs (RT>2s).
summary(data_gsls)

# defining factors
data_gsls$Subject=factor(data_gsls$Subject)
data_gsls$Block=factor(data_gsls$Block)
data_gsls$ImagePair=factor(data_gsls$ImagePair)
data_gsls$TrialOrder=factor(data_gsls$TrialOrder)
data_gsls$Order=factor(data_gsls$Order)

# Inverse RT
data_gsls$invRT=1/data_gsls$RT

# Linear Mixed Model 
library(car) # for Anova
library(lme4) # for lmer
library(lmerTest)

# RT model
LMM_BIM_RT=lmer(RT ~ Block*ImagePair+(1|Subject),contrasts=list(Block='contr.sum',ImagePair='contr.sum'), data=data_gsls,REML = FALSE) # This is a crossed design
anova(LMM_BIM_RT)
# Inverse RT model
LMM_BIM_invRT=lmer(invRT ~ Block*ImagePair+(1|Subject),contrasts=list(Block='contr.sum',ImagePair='contr.sum'), data=data_gsls,REML = FALSE) # This is a crossed design
anova(LMM_BIM_invRT)
summary(LMM_BIM_invRT)

# Alternative Linear Mixed Model
# RT model
alter_LMM_RT=lmer(RT ~ Block+(Block|Subject)+(1|ImagePair),contrasts=list(Block='contr.sum'), data=data_gsls,REML = FALSE) # This is a crossed design
anova(alter_LMM_RT)
# Inverse RT model
alter_LMM_invRT=lmer(invRT ~ Block+(Block|Subject)+(1|ImagePair),contrasts=list(Block='contr.sum'), data=data_gsls,REML = FALSE) # This is a crossed design
anova(alter_LMM_invRT)


# Post-Hoc analysis
library(plyr)
gsls_summary<-ddply(data_gsls, .(Block,ImagePair), summarize,RT = mean(RT))
gsls_summary_wide<-reshape(gsls_summary,idvar = "ImagePair",timevar="Block",v.names="RT", direction="wide", sep="_")
img_pair_GA_count=gsls_summary_wide$RT_global<gsls_summary_wide$RT_local
print("Number of Image Pairs showing Global Advantage")
summary(img_pair_GA_count)



## Repeated Measures Anova
library(plyr)
library(car)
gsls_full=Fulldata[Fulldata$Type=="GSLS",]

gsls_meandata=ddply(gsls_full, .(Subject,Block, Order,ImagePair,Type), summarize,RT = mean(RT))
gsls_meandata$invRT=1/(gsls_meandata$RT)

# factors
gsls_meandata$Subject=factor(gsls_meandata$Subject)
gsls_meandata$Block=factor(gsls_meandata$Block)
gsls_meandata$ImagePair=factor(gsls_meandata$ImagePair)


fit_repeated_measures_RT <- aov(RT ~ Block*ImagePair+Error(Subject/(Block*ImagePair)), contrasts=list(Block='contr.sum', ImagePair ='contr.sum'), data=gsls_meandata)
summary(fit_repeated_measures_RT)

fit_repeated_measures_invRT <- aov(invRT ~ Block*ImagePair+Error(Subject/(Block*ImagePair)), contrasts=list(Block='contr.sum', ImagePair ='contr.sum'), data=gsls_meandata)
summary(fit_repeated_measures_invRT)


# Normal Anova
gsls_full$Block=factor(gsls_full$Block)
gsls_full$ImagePair=factor(gsls_full$ImagePair)
gsls_full$Subject=factor(gsls_full$Subject)

gsls_full$invRT=1/gsls_full$RT

library(car)
fit_normalAnova_RT <- aov(RT ~ Block*ImagePair*Subject,contrasts=list(Block='contr.sum', ImagePair ='contr.sum', Subject='contr.sum'), data=gsls_full)
anova(fit_normalAnova_RT)

fit_normalAnova_invRT <- aov(invRT ~ Block*ImagePair*Subject,contrasts=list(Block='contr.sum', ImagePair ='contr.sum', Subject='contr.sum'), data=gsls_full)
anova(fit_normalAnova_invRT)

###########
library(MASS)
library(fitdistrplus)
library(ggplot2)

# RESIDUAL ANALYSIS 
RE_RT=residuals(LMM_BIM_RT)
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
RE_invRT=residuals(LMM_BIM_invRT)
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
pdf("GSLS_residual.pdf",width = 8,height = 8)
ggarrange(fig_A,fig_B,fig_C,fig_D,labels=c("A","B","C","D"))
dev.off()

##################### normality test
normality_RT=ks.test(RE_RT,"pnorm",mean=mean(RE_RT),sd=sd(RE_RT))
print(normality_RT)

normality_invRT=ks.test(RE_invRT,"pnorm",mean=mean(RE_invRT),sd=sd(RE_invRT))
print(normality_invRT)
#####################

