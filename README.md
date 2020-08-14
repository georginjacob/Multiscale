# Readme #
This repository contains the matlab codes to create the figures and the R codes to report the statictical significance in the manuscript "How the forest interacts with the trees: Multiscale shape integration explains global and local processing" 
by Georgin Jacob and S. P. Arun, Indian Isntitute of Science, Bangalore, INDIA.

## 1. Figure Code ##

This folder contains the Matlab codes to  create the figure pannels.

  **1.1 figure 05d**  : Seven representative shapes used in MDS plots when refering to global scale alone. 
  
  **1.2 subfunctions** : Dependent matlab subfunctions to used by the each of the figure panel codes.  
  
  **figure_XX**  : Matlab code (.m file) to generate each figure panel of the manuscript. 
  
  **L2_XX**      : There is an L2_xx.mat corresponding to each experiment (L2_SD.mat-exp01, LSmain.mat-exp02, L2_GLIE.mat-exp03, L2_IEpossizenum.mat-exp04, 
  L2_pos2.mat-exp05 and L2_IE_grouping.mat-exp06). This data stucture is formed by pooling the data from all the participants of the experiment.
  
## 2. Stats ## 
This folder contains the R codes used find the statistical significance. 

**2.1 Exp01_BlockwiseSameDifferent_HierarchicalShapes** : All files used to report stats based on experiment-1

**2.2 Exp02_VisualSearch_HierarchicalShapes** : All files used to report stats based on experiment-2

**multiscale_stats_summary.xlsx** : Summary of all the Linear Mixed model reported in the manuscripts. 


**Exp01_BlockwiseSameDifferent_HierarchicalShapes**


## 2.1 Exp01_BlockwiseSameDifferent_HierarchicalShapes ##
 **FIG_XX.R** : R codes to check the statistical significance of the effect. There is a separate code for each subpanel. 
 
 **FIG_SX.pdf** : R generated pdf files for supplimentary figure-1
 
 **GDLD_Global_Advantage_LMMoutputs.txt** : Linear Mixed Model model output for GDLD pairs with blocks and image pairs as fixed factors and Subjects as random factor.
 
 **SAME_DIFFERENT_EXP.csv** : Exp-01 data in csv format. All the R analysis is based on this csv file.
 
 **create_data_csv_EXP_01_SD.m** : Matlab code to generate the csv file from the L2_SD.mat (Consolidated experimental data of Exp-01)
 
 ## 2.1 Exp02_VisualSearch_HierarchicalShapes ##
 
**FigurXX.R** : Rcodes to check the statistical significance of the effects in exp02. There are separate codes for each panel. 

**GL_VS.csv** : Exp 01 data in csv format.

**VS_distractor_congruence.csv** : Estimated target congruence RT data for doing the stats on Figure 4G top panel. 

**VS_target_congruence.csv** : Estimated distractor congruence RT data for doing the stats on Figure 4G bottom panel.

 
