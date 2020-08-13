rm(list = ls())

DATA=read.csv(file = "GL_VS.csv")
summary(DATA)

# *****************************************
##          GLOBAL ADVANTAGE
# *****************************************

## repeated measures ANOVA for global advanatge
data_subset=DATA[!DATA$ShapeChange=="Both Change",] # selecting only global and local change
data_subset=data_subset[!is.na(data_subset$RT),]

data_subset$ShapePair=NA
data_subset$ThirdShape=NA
# global
indexG=data_subset$ShapeChange=="Global Change"
data_subset$ShapePair[indexG]=paste(data_subset$Shapeg1[indexG],"+",data_subset$Shapeg2[indexG])
data_subset$ThirdShape[indexG]=data_subset$Shapel1[indexG]
#local
indexL=data_subset$ShapeChange=="Local Change"
data_subset$ShapePair[indexL]=paste(data_subset$Shapel1[indexL],"+",data_subset$Shapel2[indexL])
data_subset$ThirdShape[indexL]=data_subset$Shapeg1[indexL]

View(data_subset)
# Factor
data_subset$ShapeChange=factor(data_subset$ShapeChange)
data_subset$ShapePair=factor(data_subset$ShapePair)
data_subset$Subject=factor(data_subset$Subject)
data_subset$Trial=factor(data_subset$Trial)
data_subset$ThirdShape=factor(data_subset$ThirdShape)
data_subset$invRT=1/(data_subset$RT)


## LINEAR MIXED MODEL
library(car) # for Anova
library(lme4) # for lmer
library(lmerTest)

fit_RT_lm = lmer(RT ~ (ShapeChange * ShapePair*ThirdShape) + (1|Subject),contrasts=list(ShapeChange='contr.sum', ShapePair ='contr.sum'), data=data_subset,REML = FALSE)
anova(fit_RT_lm)

fit_inv_lm = lmer(invRT ~ (ShapeChange * ShapePair*ThirdShape) + (1|Subject),contrasts=list(ShapeChange='contr.sum', ShapePair ='contr.sum'), data=data_subset,REML = FALSE)
anova(fit_inv_lm)


# Post-Hoc analysis
library(plyr)
data_summary<-ddply(data_subset, .(ShapeChange,ShapePair,ThirdShape), summarize,RT = mean(RT))
data_summary_wide<-reshape(data_summary,idvar = c("ShapePair","ThirdShape"),timevar="ShapeChange",v.names="RT", direction="wide", sep="_")
img_pair_count=data_summary_wide$`RT_Global Change`<data_summary_wide$`RT_Local Change`
print("Number of unique (Shape Pairs+ShapeChange) showing Global Advantage")
summary(img_pair_count)

#################### RESIDUALS ##################################
library(MASS)
library(fitdistrplus)
library(ggplot2)

RE_RT=residuals(fit_RT_lm)
fit_norm_RT<- fitdist(RE_RT, "norm",method="mle")
fig_A<-denscomp(list(fit_norm_RT),main="Distribution of LMM on RT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-7,7),
                breaks = 24,
                dempcol="blue")+
  geom_line(color="Red",size=1)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_B<-qqcomp(list(fit_norm_RT),main="QQ plot-RT model",plotstyle="ggplot",xlim=c(-7,7),ylim=c(-7,7),show.legend = FALSE)+
  geom_point(color="Red",size=1,shape=19)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())+
  theme(legend.position = "none")

#invRT
RE_invRT=residuals(fit_inv_lm)
fit_norm_invRT<- fitdist(RE_invRT, "norm",method="mle")
fig_C<-denscomp(list(fit_norm_invRT),main="Distribution of LMM on invRT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-2,2), breaks = 20)+
  geom_line(color="Red",size=1)+
  theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_D<-qqcomp(list(fit_norm_invRT),main="QQ plot-inv RT model",plotstyle="ggplot",xlim=c(-2,2),ylim=c(-2,2),show.legend = FALSE)+
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
###################################################################

# ###############################
#         INCONGRUENCE
# ###############################
# Congruence
data_subset=DATA[!DATA$congruence=="NaN",] 
data_subset$image_pairs[data_subset$congruence=="Congruent"]=paste(data_subset$Shapeg1[data_subset$congruence=="Congruent"],data_subset$Shapeg2[data_subset$congruence=="Congruent"])
data_subset$image_pairs[data_subset$congruence=="Incongruent"]=paste(data_subset$Shapeg2[data_subset$congruence=="Incongruent"],data_subset$Shapel2[data_subset$congruence=="Incongruent"])

# Shape Pair
sel_index=data_subset$Shapeg1<data_subset$Shapeg2
data_subset$ShapePair[sel_index]=paste(data_subset$Shapeg1[sel_index],"+",data_subset$Shapeg2[sel_index])
sel_index=data_subset$Shapeg1>data_subset$Shapeg2
data_subset$ShapePair[sel_index]=paste(data_subset$Shapeg2[sel_index],"+",data_subset$Shapeg1[sel_index])
data_subset$invRT=1/(data_subset$RT)

# FACTORS
data_subset$congruence=factor(data_subset$congruence)
data_subset$ShapePair=factor(data_subset$ShapePair)
data_subset$Subject=factor(data_subset$Subject)
data_subset$Trial=factor(data_subset$Trial)

fit_RT_lm_CI = lmer(RT ~ (congruence * ShapePair) + (1|Subject), contrasts=list(congruence='contr.sum', ShapePair ='contr.sum'),data=data_subset,REML=FALSE)
anova(fit_RT_lm_CI)


fit_inv_lm_CI = lmer(invRT ~ (congruence * ShapePair) + (1|Subject), contrasts=list(congruence='contr.sum', ShapePair ='contr.sum'),data=data_subset,REML=FALSE)
anova(fit_inv_lm_CI)

## Post-Hoc Analysis
library(plyr)
dat_summary_conc_temp=ddply(data_subset,c("congruence","ShapePair"),summarise, meanRT=mean(RT),std=sd(RT,na.rm = FALSE))
dat_summary_conc=ddply(dat_summary_conc_temp,c("congruence"),summarise, RT=mean(meanRT),std=sd(meanRT))

View(dat_summary_conc)

data_summary_wide<-reshape(dat_summary_conc_temp,idvar = "ShapePair",timevar="congruence",v.names=c("meanRT","std"), direction="wide", sep="_")
img_pair_count=data_summary_wide$meanRT_Congruent< data_summary_wide$meanRT_Incongruent
print("Number of unique (Image Pairs) showing Incongruence")
summary(img_pair_count)


#################### RESIDUALS ##################################
library(MASS)
library(fitdistrplus)
library(ggplot2)

RE_RT=residuals(fit_RT_lm_CI)
fit_norm_RT<- fitdist(RE_RT, "norm",method="mle")
fig_A<-denscomp(list(fit_norm_RT),main="Distribution of LMM on RT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-5,5),
                breaks = 24,
                dempcol="blue")+
  geom_line(color="Red",size=1)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_B<-qqcomp(list(fit_norm_RT),main="QQ plot-RT model",plotstyle="ggplot",xlim=c(-5,5),ylim=c(-5,5),show.legend = FALSE)+
  geom_point(color="Red",size=1,shape=19)+theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())+
  theme(legend.position = "none")

#invRT
RE_invRT=residuals(fit_inv_lm_CI)
fit_norm_invRT<- fitdist(RE_invRT, "norm",method="mle")
fig_C<-denscomp(list(fit_norm_invRT),main="Distribution of LMM on invRT data",
                plotstyle="ggplot",xlab = "Residuals",
                ylab='Density',
                fittype="p",
                xlim=c(-2,2), breaks = 20)+
  geom_line(color="Red",size=1)+
  theme_bw()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank())

fig_D<-qqcomp(list(fit_norm_invRT),main="QQ plot-inv RT model",plotstyle="ggplot",xlim=c(-2,2),ylim=c(-2,2),show.legend = FALSE)+
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
###################################################################



## ***************************
#       INCONGRUENCE
## ***************************

## repeated measures ANOVA for congruence
# Congruence
data_subset=DATA[!DATA$congruence=="NaN",] 
data_subset$image_pairs[data_subset$congruence=="Congruent"]=paste(data_subset$Shapeg1[data_subset$congruence=="Congruent"],data_subset$Shapeg2[data_subset$congruence=="Congruent"])
data_subset$image_pairs[data_subset$congruence=="Incongruent"]=paste(data_subset$Shapeg2[data_subset$congruence=="Incongruent"],data_subset$Shapel2[data_subset$congruence=="Incongruent"])

# Shape Pair
sel_index=data_subset$Shapeg1<data_subset$Shapeg2
data_subset$ShapePair[sel_index]=paste(data_subset$Shapeg1[sel_index],"+",data_subset$Shapeg2[sel_index])
sel_index=data_subset$Shapeg1>data_subset$Shapeg2
data_subset$ShapePair[sel_index]=paste(data_subset$Shapeg2[sel_index],"+",data_subset$Shapeg1[sel_index])

data_subset$invRT=1/(data_subset$RT)

# FACTORS
data_subset$congruence=factor(data_subset$congruence)
data_subset$ShapePair=factor(data_subset$ShapePair)
data_subset$Subject=factor(data_subset$Subject)
data_subset$Trial=factor(data_subset$Trial)

#RT
fit_na <- aov(RT ~ congruence*ShapePair*Subject,contrasts=list(congruence='contr.sum', ShapePair ='contr.sum', Subject = 'contr.sum'), data=data_subset)
Anova(fit_na, type=3)

#1/RT
fit_inv_na <- aov(invRT ~ congruence*ShapePair*Subject, data=data_subset)
Anova(fit_inv_na, type=3)

# Repeated Measures ANOVA
# Average
library(plyr)
meandata=ddply(data_subset, .(Subject,ShapePair, congruence), summarize,RT = mean(RT))
meandata$invRT=1/(meandata$RT)

# RT
fit_ra=aov(RT~congruence*ShapePair+Error(Subject/(congruence*ShapePair)),data=meandata)
summary(fit_ra)

# 1/RT
fit_inv_ra=aov(invRT~congruence*ShapePair+Error(Subject/(congruence*ShapePair)),data=meandata)
summary(fit_inv_ra)


# Linear Mixed Model
library(car) # for Anova
library(lme4) # for lmer
library(lmerTest)

# RT
fit_lm_CI = lmer(RT ~ (congruence * ShapePair) + (1|Subject),contrasts=list(congruence='contr.sum', ShapePair ='contr.sum'), data=data_subset)
Anova(fit_lm_CI, type=3)

# 1/RT
fit_inv_lm_CI = lmer(invRT ~ (congruence * ShapePair) + (1|Subject), data=data_subset)
Anova(fit_inv_lm_CI,type=3)

## Plotting
library(MASS)
library(fitdistrplus)
library(ggplot2)

# RT
RE_rt_CI=residuals(fit_lm_CI)
fit_norm<- fitdist(RE_rt_CI, "norm")
fig_RT_d_CI=denscomp(list(fit_norm),main="RT model, CI",plotstyle="ggplot")+geom_line(color="Red",size=1)+geom_point(color="Red",size=.5)+theme_bw()
fig_RT_qq_CI=qqcomp(list(fit_norm),main="RT model, CI",plotstyle="ggplot")+geom_point(color="Red",size=1)+theme_bw()  

#1/RT
RE_inv_rt_CI=residuals(fit_inv_lm_CI)
fit_norm_inv<- fitdist(RE_inv_rt_CI, "norm")
fig_invRT_d_CI=denscomp(list(fit_norm_inv),main="1/RT model, CI",plotstyle="ggplot")+geom_line(color="Red",size=1)+geom_point(color="Red",size=.5)+theme_bw()
fig_invRT_qq_CI=qqcomp(list(fit_norm_inv),main="1/RT model, CI",plotstyle="ggplot")+geom_point(color="Red",size=1)+theme_bw()  


# One Sample Kolmogorov-Smirnow Test 
# p-value > 0.05 shows that the test distribution is normal.  
fit_estimate=fit_norm_inv$estimate
ks.test(RE_inv_rt_CI[1:4000],"pnorm",fit_estimate[1],fit_estimate[2],exact=TRUE) # taking 4000 sample to make the computation quicker

library("ggpubr")
ggarrange(fig_RT_d_CI, fig_RT_qq_CI, fig_invRT_d_CI, fig_invRT_qq_CI,labels = c("A", "B","C","D"),ncol = 2, nrow = 2)



