##############################################################
#  Individual Vs. Measure Variance in Overprecision (IMO)
#  Randall Hale, Don A. Moore
#  November 2021
##############################################################

# Initializing data, packages, and functions

#####

# Importing Data

IMO = read.csv('IMO Data.csv')[-c(1:2), -c(1:2,4,8:17)]

# Converting to Numeric

for(i in 1:115){
  IMO[,i] = as.numeric(IMO[,i])
}

# Importing Required Packages

if("lme4" %in% rownames(installed.packages()) == F) {
  install.packages("lme4")
}
if("xtable" %in% rownames(installed.packages()) == F) {
  install.packages("xtable")
}
if("Hmisc" %in% rownames(installed.packages()) == F) {
  install.packages("Hmisc")
}

library(lme4)
library(xtable)
library(Hmisc)

# Defining SPD Variance Function

spd_calc = function(row) {
  
  row_sum = sum(row)
  row = round(row/row_sum, 2)
  
  # deriving estimate
  est = 0
  for(i in 0:10){
    est = est + row[i+1]*i
  }
  
  # deriving variance
  var = 0
  for(i in 0:10){
    var = var + row[i+1]*(i - est)^2
  }
  
  # determining peak bin
  peak = which(row == max(row))[1]
  
  maxd = max(row)
  
  return(c(round(var,2), est, peak-1, maxd))
}

# Defining correlation table function

corstars <-function(x, method=c("pearson", "spearman"), removeTriangle=c("upper", "lower"),
                    result=c("none", "html", "latex")){
  #Compute correlation matrix
  require(Hmisc)
  x <- as.matrix(x)
  correlation_matrix<-rcorr(x, type=method[1])
  R <- correlation_matrix$r # Matrix of correlation coeficients
  p <- correlation_matrix$P # Matrix of p-value 
  
  ## Define notions for significance levels; spacing is important.
  mystars <- ifelse(p < .0001, "****", "    ")
  
  ## trunctuate the correlation matrix to two decimal
  R <- format(round(cbind(rep(-1.11, ncol(x)), R), 2))[,-1]
  
  ## build a new matrix that includes the correlations with their apropriate stars
  Rnew <- matrix(paste(R, mystars, sep=""), ncol=ncol(x))
  diag(Rnew) <- paste(diag(R), " ", sep="")
  rownames(Rnew) <- colnames(x)
  colnames(Rnew) <- paste(colnames(x), "", sep="")
  
  ## remove upper triangle of correlation matrix
  if(removeTriangle[1]=="upper"){
    Rnew <- as.matrix(Rnew)
    Rnew[upper.tri(Rnew, diag = TRUE)] <- ""
    Rnew <- as.data.frame(Rnew)
  }
  
  ## remove lower triangle of correlation matrix
  else if(removeTriangle[1]=="lower"){
    Rnew <- as.matrix(Rnew)
    Rnew[lower.tri(Rnew, diag = TRUE)] <- ""
    Rnew <- as.data.frame(Rnew)
  }
  
  ## remove last column and return the correlation matrix
  Rnew <- cbind(Rnew[1:length(Rnew)-1])
  if (result[1]=="none") return(Rnew)
  else{
    if(result[1]=="html") print(xtable(Rnew), type="html")
    else print(xtable(Rnew), type="latex") 
  }
} 

#####

# Exclusions

#####

IMO = IMO[IMO$Progress == 100,]
IMO = IMO[IMO$Status == 0,]
IMO = IMO[IMO$Duration..in.seconds. > 300,]

# Comprehension Quiz

comp_score = array(rep(0, nrow(IMO)))
comp_key = c(3,4,3,3,2)

for(i in 1:5){
  
  comp_score = comp_score + as.numeric(IMO[,i+5] == comp_key[i])
  
}

IMO = IMO[comp_score >= 3,]

#####

# Marble Guessing Task

#####

# Calculating Score

limbo = 50

key = c(180,285,352,412,500,620,697,750,831,911)

IMO$Score = array(rep(0,nrow(IMO)))

for(i in 1:10){
  
  IMO$Score = IMO$Score + as.numeric(abs(IMO[,i+25] - key[i]) < limbo) 

}

# Self Score Point Estimate Accuracy

IMO$Accurate = abs(IMO$MGT_EST_1 - IMO$Score) < 2


### Bonus

# Reformatting NUM, LIK and BET Confidence Values

IMO$Numeric = NA
IMO$Likert = NA
IMO$Bet = NA

for(i in 1:nrow(IMO)){
  
  IMO$Numeric[i] = IMO[i,52:54][!is.na(IMO[i,52:54])]
  IMO$Likert[i] = IMO[i,55:57][!is.na(IMO[i,55:57])]
  IMO$Bet[i] = IMO[i,58:60][!is.na(IMO[i,58:60])]
  
  
}


# Calculating Bonus

IMO$Bonus = NA

for(i in 1:nrow(IMO)) {
  
  if(!IMO$Accurate[i]) {
    IMO$Bonus[i] = 1 - IMO$Bet[i]
  }
  else if(IMO$Accurate[i]) {
    IMO$Bonus[i] = 1-IMO$Bet[i] + 2*IMO$Bet[i]
  }
}

#####

# Overconfidence

#####

### Overprecision

## Pre-Task

# SPD Variance

IMO$SPDvar_PRE = NA

for(i in 1:nrow(IMO)) {
  IMO$SPDvar_PRE[i] = unlist(spd_calc(IMO[i,15:25])[1])
}

## Post-Task

# SPD Variance & Peak

IMO$SPDvar_POST = NA
IMO$SPD_Est = NA
IMO$SPD_Peak = NA

for(i in 1:nrow(IMO)) {
  output = unlist(spd_calc(IMO[i,40:50]))
  IMO$SPDvar_POST[i] = output[1]
  IMO$SPD_Est[i] = output[2]
  IMO$SPD_Peak[i] = output[4]
}

# 50% CI

IMO$Width_50CI = abs(IMO$X75th_1 - IMO$X25th_1)

# 80% CI

IMO$Width_80CI = abs(IMO$X90th_1 - IMO$X10th_1)

# 90% CI

IMO$Width_90CI = abs(IMO$X90CI_conf_2 - IMO$X90CI_conf_1)


### Overestimation

IMO$Overestimation = IMO$SPD_Est - IMO$Score


### Overplacement

IMO$Overplacment = NA

for(i in 1:nrow(IMO)) {
  output = unlist(spd_calc(IMO[i,71:81]))
  IMO$Overplacment[i] = (IMO$SPD_Est[i] - output[2]) - (IMO$Score[i] - mean(IMO$Score))
}

#####

# Individual Difference Measures

#####

# Intellectual Humility

IMO$IH = round(rowMeans(6-IMO[,82:86]),2)

# General Humility

IMO$Humility = round(rowMeans(cbind(6-IMO[,87:93], IMO$HHS4_24, IMO$HHS4_48, 6-IMO$HHS4_72R, 6-IMO$HHS4_96R)),2)

# Narcissism 

IMO$Narcissism = round(rowMeans(cbind(IMO[,c(99,101,102,104,107,109,110,112)], 
               1 - IMO[,c(98,100,103,105,106,108,111,113)])),2)

#####

# Precision Analyses (Hypotheses 1 & 2)

#####

precision_data = data.frame(CI_Width_90 = IMO$Width_90CI, CI_Width_80 = IMO$Width_80CI,
                          CI_Width_50 = IMO$Width_50CI, Bet_Confidence = IMO$Bet,
                          SPD_Var = IMO$SPDvar_POST, SPD_Peak = IMO$SPD_Peak, 
                          Numeric_Confidence = IMO$Numeric, Likert_Confidence = IMO$Likert)

# Standardizing all measures to fit a 0-100 range

precision_data[,1:3] = (10 - precision_data[,1:3])*10
precision_data[,4] = precision_data[,4]*100
precision_data[,5] = 100*((20 - precision_data[,5])/20)
precision_data[,6] = precision_data[,6]*100
precision_data[,8] = precision_data[,8]*100/7


## Determining average bivariate correlation

indices = array(1:8)
cor_bank = array()
p = 1
for(i in indices) {
  for(j in indices[-c(i)]) {
    cor_bank[p] = unlist(cor.test(precision_data[,i], precision_data[,j])[4])
    p = p + 1
  }
}

# All unique bivariate correlations between precision measures (28 total)

act_corr = round(unique(cor_bank),2)

## Creating new dataframe

mix = data.frame('score' = NA, 'measure' = NA, 'id' = NA)[-c(1),]
count = 1
for(i in 1:nrow(precision_data)){
  for(j in 1:ncol(precision_data)){
    mix[count, 1] = precision_data[i,j]
    mix[count, 2] = colnames(precision_data)[j]
    mix[count, 3] = i
    count = count + 1
  }
}

mix[,1] = round(mix[,1])


## Cross-Classified Multilevel Model

mix_mod = lmer(score ~ (1|measure) + (1|id), data = mix)
summary(mix_mod)


# Bootstrapping 

vars = data.frame('IND' = NA, 'MEAS' = NA)

for(i in 1:1000){
  mod = lmer(score ~ (1|measure) + (1|id), data = mix[sample(1:nrow(mix),300, replace = T),])
  
  vars[i,] = unlist(summary(mod)$varcor[1:2])
}

# t-test to determine if variances are distinct

ind_variance = vars[,1]
meas_variance = vars[,2]

par(mfrow = c(1,2))
hist(ind_variance, breaks = 100, xlim = c(0,300))
hist(meas_variance, breaks = 100, xlim = c(0,300))


### HYPOTHESIS 1 TEST

t.test(ind_variance, meas_variance)


### Simulating Data for Comparison

SPDs = data.frame(matrix(NA, nrow = 1000, ncol = 110))
minSPDs = data.frame(matrix(NA, nrow = nrow(SPDs), ncol = 11))
means = array()
sds = array()
percentiles = data.frame('5th' = rep(NA, 1000), '10th' = rep(NA, 1000), '25th' = rep(NA, 1000),
                         '75th' = rep(NA, 1000), '90th' = rep(NA, 1000), '95th' = rep(NA, 1000))
cutoffs = c(.05, .10, .25, .75, .90, .95)

# Creating distribution from density function

for(i in 1:1000){
  sd = round(runif(1, 5, 20),0)
  mean = round(runif(1, 0, 100),0)
  sample = c(0,0,0,0,0, dnorm(seq(1,100), mean, sd), 0,0,0,0,0)
  SPDs[i,] = sample/sum(sample)
  for(j in 0:10) {
    minSPDs[i,j+1] = round(sum(SPDs[i,(j*10):((j+1)*10-1)]),2)
  }
  means[i] = mean
  sds[i] = sd
  for(l in 1:6) {
    if(qnorm(cutoffs[l], mean, sd) < 0) {
      percentiles[i, l] = 0
    }
    else if(qnorm(cutoffs[l], mean, sd) > 100) {
      percentiles[i, l] = 100
    }
    else {
      percentiles[i, l] = qnorm(cutoffs[l], mean, sd) 
    }
  }
  
}

percentiles = round(percentiles,0)

# Graphing distributions

# par(mfrow = c(3,3))
# for(i in 5:8) {
#   barplot(unlist(SPDs[i,5:105]), xlim = c(0,100))
#   barplot(unlist(minSPDs[i,]), xlim = c(1,11))
# }

# barplot(unlist(minSPDs[10,]), xlim = c(0,12), xlab = 'Percentage', ylab = 'Subjective Probability')

## Finding SPD var and SPD peak for minSPDs

minSPDs$Est = NA
minSPDs$SPDvar = NA
minSPDs$SPDpeak = NA

for(i in 1:nrow(minSPDs)){
  output = unlist(spd_calc(minSPDs[i,1:11]))
  peak = output[3]*10
  low = ifelse(peak-5 < 0, 0, peak-5)
  high = ifelse(peak+5 > 100, 100, peak + 5)
  
  minSPDs$SPDvar[i] = output[1]
  minSPDs$Est[i] = round(output[2],0)
  minSPDs$SPDpeak[i] = round(sum(SPDs[i,1:110][low:high]),2)
}

## Calculating CIs

SPDs$width_90 = percentiles$X95th - percentiles$X5th
SPDs$width_80 = percentiles$X90th - percentiles$X10th
SPDs$width_50 = percentiles$X75th - percentiles$X25th

# Calculating bet and numeric confidence scores

SPDs$bet = NA
SPDs$numeric = NA
for(i in 1:nrow(SPDs)) {
  
  min = minSPDs$Est[i]*10 - 10
  max = minSPDs$Est[i]*10 + 10
  if(min < 0) {
    min = 0
  }
  if(max > 100) {
    max = 100
  }
  SPDs$numeric[i] = round(sum(SPDs[i,min:max])*100, 0)
  if(SPDs$numeric[i] >= 50) {
    SPDs$bet[i] = 1
  }
  else {
    SPDs$bet[i] = 0
  }
}

# Calculating likert confidence
SPDs$likert = round(7*SPDs$numeric/100,0)

# Combining all measures; re-scoring such that higher scores indicate less precision

sim_data = data.frame(SPDs$width_90, SPDs$width_80, SPDs$width_50, SPDs$bet, minSPDs$SPDvar, minSPDs$SPDpeak, SPDs$numeric, SPDs$likert)

# Standardizing all measures to fit a 0-100 range

sim_data[,1:3] = (10 - sim_data[,1:3])*10
sim_data[,4] = sim_data[,4]*100
sim_data[,5] = 100*((20 - sim_data[,5])/20)
sim_data[,6] = sim_data[,6]*100
sim_data[,8] = sim_data[,8]*100/7


# Calculating average correlation of 21 total correlations (7 measures)

indices = array(1:8)
sim_bank = array()
p = 1
for(i in indices) {
  for(j in indices[-c(i)]) {
    sim_bank[p] = unlist(cor.test(sim_data[,i], sim_data[,j])[4])
    p = p + 1
  }
}

sim_corr = unique(sim_bank)
mean(sim_corr)
cor(sim_data)
# Mean correlation: .81

### HYPOTHESIS 2 TEST

t.test(act_corr, sim_corr)


#####

# Individual Differences and Precision Analyses (Hypotheses 3-5)

#####

precision_data$Gender = IMO$GENDER # 1 = Male, 2 = Female, 3 = Other, 4 = Declined
precision_data$Age = IMO$AGE
precision_data$IH = IMO$IH
precision_data$Humility = IMO$Humility
precision_data$Narcissism = IMO$Narcissism


cor_bank = array()
p = 1
for(i in 1:8){
  for(j in 9:13){
    cor_bank[p] = unlist(cor.test(precision_data[,i], precision_data[,j])[4])
    p = p + 1
  }
}

# HYPOTHESIS 3 TEST

max(cor_bank) < .4


# HYPOTHESIS 4 TEST

cor_bank = array(c(unlist(cor.test(precision_data$IH, precision_data$SPD_Var)[4]), 
             unlist(cor.test(precision_data$Humility, precision_data$SPD_Var)[4])))

max(cor_bank) < .32

# HYPOTHESIS 5 TEST

cor.test(IMO$SPDvar_POST, IMO$Humility)
cor.test(IMO$SPDvar_PRE, IMO$Humility)

# Comprehensive correlation table

corstars(precision_data, result = 'html')

#####

