# This code contain all the codes done in Figure-1 (SD)
rm(list=ls())

Fulldata=read.csv("SAME_DIFFERENT_EXP.csv")
summary(Fulldata) # Check the data

# Selecting GDLD Data from the full data 
data_gdld=Fulldata[Fulldata$Type=="GDLD"& Fulldata$Outliers==0 &Fulldata$RT>0.3&Fulldata$RT<2,] # Removing fast RT's (RT< 300 ms) and very slow RTs (RT>2s).
summary(data_gdld)

# defining factors
data_gdld$Subject=factor(data_gdld$Subject)
data_gdld$Block=factor(data_gdld$Block)
data_gdld$ImagePair=factor(data_gdld$ImagePair)
data_gdld$TrialOrder=factor(data_gdld$TrialOrder)
data_gdld$Order=factor(data_gdld$Order)

# Inverse RT
data_gdld$invRT=1/data_gdld$RT

# Linear Mixed Model 
library(car) # for Anova
library(lme4) # for lmer
library(lmerTest)

# RT model
LMM_BIM_RT=lmer(RT ~ Block*ImagePair+(1|Subject),contrasts=list(Block='contr.sum',ImagePair='contr.sum'), data=data_gdld,REML = FALSE) # This is a crossed design
anova(LMM_BIM_RT)

# Inverse RT model
LMM_BIM_invRT=lmer(invRT ~ Block*ImagePair+(1|Subject),contrasts=list(Block='contr.sum',ImagePair='contr.sum'), data=data_gdld,REML = FALSE) # This is a crossed design
anova(LMM_BIM_invRT)
summary(LMM_BIM_invRT)

# Post-Hoc analysis
library(plyr)
gdld_full=Fulldata[Fulldata$Type=="GDLD",]
gdld_summary<-ddply(data_gdld, .(Block,ImagePair), summarize,RT = mean(RT))
gdld_summary_wide<-reshape(gdld_summary,idvar = "ImagePair",timevar="Block",v.names="RT", direction="wide", sep="_")
img_pair_GA_count=gdld_summary_wide$RT_global<gdld_summary_wide$RT_local
print("Number of Image Pairs showing Global Advantage")
summary(img_pair_GA_count)

## Repeated Measures Anova
library(plyr)
library(car)
gdld_full=Fulldata[Fulldata$Type=="GDLD",]

gdld_meandata=ddply(gdld_full, .(Subject,Block, Order,ImagePair,Type), summarize,RT = mean(RT))
gdld_meandata$invRT=1/(gdld_meandata$RT)

# factors
gdld_meandata$Subject=factor(gdld_meandata$Subject)
gdld_meandata$Block=factor(gdld_meandata$Block)
gdld_meandata$ImagePair=factor(gdld_meandata$ImagePair)

fit_repeated_measures_invRT <- aov(invRT ~ Block*ImagePair+Error(Subject/(Block*ImagePair)), contrasts=list(Block='contr.sum', ImagePair ='contr.sum'), data=gdld_meandata)
summary(fit_repeated_measures_invRT)
fit_repeated_measures_RT <- aov(RT ~ Block*ImagePair+Error(Subject/(Block*ImagePair)), contrasts=list(Block='contr.sum', ImagePair ='contr.sum'), data=gdld_meandata)
summary(fit_repeated_measures_RT)

# Normal Anova
gdld_full$Block=factor(gdld_full$Block)
gdld_full$ImagePair=factor(gdld_full$ImagePair)
gdld_full$Subject=factor(gdld_full$Subject)

gdld_full$invRT=1/gdld_full$RT

library(car)
fit_normalAnova_RT <- aov(RT ~ Block*ImagePair*Subject,contrasts=list(Block='contr.sum', ImagePair ='contr.sum', Subject='contr.sum'), data=gdld_full)
anova(fit_normalAnova_RT)

fit_normalAnova_invRT <- aov(invRT ~ Block*ImagePair*Subject,contrasts=list(Block='contr.sum', ImagePair ='contr.sum', Subject='contr.sum'), data=gdld_full)
anova(fit_normalAnova_invRT)


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
pdf("Fig_S1.pdf",width = 8,height = 8)
ggarrange(fig_A,fig_B,fig_C,fig_D,labels=c("A","B","C","D"))
dev.off()

pdf("Fig_S1A.pdf",width = 4,height = 4)
ggarrange(fig_A,labels=c("A"))
dev.off()

pdf("Fig_S1B.pdf",width = 4,height = 4)
ggarrange(fig_B,labels=c("B"))
dev.off()

pdf("Fig_S1C.pdf",width = 4,height = 4)
ggarrange(fig_C,labels=c("C"))
dev.off()

pdf("Fig_S1D.pdf",width = 4,height = 4)
ggarrange(fig_D,labels=c("D"))
dev.off()

##################### normality test
normality_RT=ks.test(RE_RT,"pnorm",mean=mean(RE_RT),sd=sd(RE_RT))
print(normality_RT)

normality_invRT=ks.test(RE_invRT,"pnorm",mean=mean(RE_invRT),sd=sd(RE_invRT))
print(normality_invRT)
#####################

options(max.print=5000)
sink(file="GDLD_Global_Advantage_LMMoutputs.txt")
print("*************************** ANOVA ***********************************")
anova(LMM_BIM_invRT)
print("*************************** Summary ***********************************")
summary(LMM_BIM_invRT)
print("*************************** Fixed Effect Coeff. ************************")
fixef(LMM_BIM_invRT)
#confint(LMM_BIM_invRT)
print("*************************** Random Effect Coeff. ************************")
ranef(LMM_BIM_invRT)
sink(file=NULL)
closeAllConnections()












