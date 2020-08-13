# SD Analysis
# Interference Effect

rm(list=ls())

Fulldata=read.csv("SAME_DIFFERENT_EXP.csv")
summary(Fulldata)

# Linear Mixed Model
library(car) # for Anova
library(lme4) # for lmer
library(lmerTest)

# ***************************** Interference in Global Block: GSLS versus GSLD comparisons **************************************************
# Discarding all correct RTs less than 300 ms
data_global_block=Fulldata[(Fulldata$Type=="GSLS"|Fulldata$Type=="GSLD") & Fulldata$Outliers==0 & Fulldata$RT>0.3 &Fulldata$Block=="global",]
data_global_block$invRT=1/(data_global_block$RT)

# factors
data_global_block$Subject=factor(data_global_block$Subject)
data_global_block$Type=factor(data_global_block$Type)

# Linear Mixed Model
LMM_RT = lmer(RT ~ (Type) + (1|Subject),contrasts=list(Type='contr.sum'), data=data_global_block,REML = FALSE)
anova(LMM_RT)

LMM_invRT = lmer(invRT ~ (Type) + (1|Subject),contrasts=list(Type='contr.sum'), data=data_global_block,REML = FALSE)
anova(LMM_invRT)



# ***************************** Interference in Local Block: GSLS versus GDLS comparisons ****************************************************
# Discarding all correct RTs less than 300 ms
data_local_block=Fulldata[(Fulldata$Type=="GSLS"|Fulldata$Type=="GDLS") &Fulldata$Block=="local" & Fulldata$Outliers==0 & Fulldata$RT>0.3,]
data_local_block$invRT=1/(data_local_block$RT)

summary(data_local_block)

# factors
data_local_block$Subject=factor(data_local_block$Subject)
data_local_block$Type=factor(data_local_block$Type)

# Linear Mixed Model
LMM_local_block_GtoL_inter_RT = lmer(RT ~ (Type) + (1|Subject),contrasts=list(Type='contr.sum'), data=data_local_block,REML = FALSE)
anova(LMM_local_block_GtoL_inter_RT)
LMM_local_block_GtoL_inter_invRT = lmer(invRT ~ (Type) + (1|Subject),contrasts=list(Type='contr.sum'), data=data_local_block,REML = FALSE)
anova(LMM_local_block_GtoL_inter_invRT)
#********************************************************************************************************************************************** 

# ******************************* Comparing Interference **************************************************************************************
data=Fulldata[(Fulldata$Type=="GSLS"|Fulldata$Type=="GDLS"|Fulldata$Type=="GSLD") & Fulldata$Outliers==0 & Fulldata$RT>0.3,]
data$inter="ABSENT"
pre_index=(data$Type=="GDLS")|(data$Type=="GSLD")
data$inter[pre_index]="PRESENT"
data$inter=factor(data$inter)

data$invRT=1/data$RT

data$Block=factor(data$Block)

LMM_interference_RT = lmer(RT ~ inter*Block + (1|Subject),contrasts=list(inter='contr.sum',Block='contr.sum'), data=data,REML = FALSE)
anova(LMM_interference_RT)

LMM_interference_invRT = lmer(invRT ~ inter*Block + (1|Subject),contrasts=list(inter='contr.sum',Block='contr.sum'), data=data,REML = FALSE)
anova(LMM_interference_invRT)
summary(LMM_interference_invRT)

# Summary
IE_summary=ddply(data, .(inter, Block), summarize,RT = mean(RT),RT_sd = sd(RT),invRT=(mean(1/RT)),invRT_sd=(sd(1/RT)))
print(IE_summary)

library(dplyr)
data$invRT=1/data$RT
grouped <- group_by(data, Block, inter)
summarise(grouped, meanRT=mean(RT), sdRT=sd(RT),meanInvRT=mean(invRT), sdInvRT=sd(invRT))



# RESIDUAL ANALYSIS 
RE_RT=residuals(LMM_interference_RT)
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
RE_invRT=residuals(LMM_interference_invRT)
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

