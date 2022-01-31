##############################################################
#  EDH
#  Don Moore, Tory Taylor, and Randall Hale
#  Jan 12, 2022
##############################################################

# installing necessary packages

if("readr" %in% rownames(installed.packages()) == F) {
  install.packages("readr")
} 

if("Dict" %in% rownames(installed.packages()) == F) {
  install.packages("Dict")
} 

if("ggplot2" %in% rownames(installed.packages()) == F) {
  install.packages("ggplot2",dependencies=TRUE)
} 
if("reshape2" %in% rownames(installed.packages()) == F) {
  install.packages("reshape2",dependencies=TRUE)
} 

library(readr)
library(Dict)
library(ggplot2)
library(reshape2)

# importing data

raw_data = read.csv('EDH.csv', na.strings=c("","NA"))[-c(1,2),]

raw_data = raw_data[raw_data$Progress == 100,] #keep only those who have completed the survey

raw_data = raw_data[raw_data$edh_consent == 1,] #keep only those who have provided consent


# [INACTIVE] excluding participants who completed survey in less than 2 minutes

raw_data = raw_data[as.numeric(raw_data$Duration..in.seconds.) >= 120,]


# moving participant ID column

raw_data[,ncol(raw_data)+1] = raw_data$ResponseId


# deleting unnecessary columns

raw_data = raw_data[,182:ncol(raw_data)]


# removing completely empty / null rows

raw_data = raw_data[rowSums(is.na(raw_data)) != 123,]


### DO NOT REMOVE ROWS PAST THIS POINT


# isolating image per bin descriptions

rand_image = raw_data[,115:124]


# isolating participant IDs

IDs = raw_data[,ncol(raw_data)]


# processing bin randomization data

bin_order = data.frame(matrix(NA, nrow = 1, ncol = 5))

rand_dict = dict('FL_648' = 2, 'FL_649' = 4, 'FL_650' =	6, 'FL_651' =	8, 'FL_652' =	10, 
                 'FL_653' =	12, 'FL_654' =	14, 'FL_655' =	16, 'FL_656' =	18, 'FL_657' =	20)

for(i in 1:nrow(raw_data)){
  bin_order[i,] = unlist(strsplit(raw_data$FL_7_DO[i], '|', fixed = T))
  
  for(j in 1:5){
    bin_order[i,j] = rand_dict[bin_order[i,j]]
  }
}


# removing randomization order from raw_data

raw_data = raw_data[,1:110]


# initializing cleaned data-frame

EDH = data.frame(ID = NA, Round = NA, Bins = NA, Image = NA, Peak = NA, Num_On_Peak = NA, 
                 Corr_Bin = NA, Conf_Corr = NA, Hit = NA, Overprecision = NA, QSR = NA, 
                 Bin1 = NA, Bin2 = NA, Bin3 = NA, Bin4 = NA, Bin5 = NA, Bin6 = NA, Bin7 = NA, 
                 Bin8 = NA, Bin9 = NA, Bin10 = NA, Bin11 = NA, Bin12 = NA, Bin13 = NA, Bin14 = NA, 
                 Bin15 = NA, Bin16 = NA, Bin17 = NA, Bin18 = NA, Bin19 = NA, Bin20 = NA)

EDH = EDH[-c(1),]


### populating cleaned data-frame


# initializing function for processing rows

processor = function(participant_row, order, ID, images) {
  
  current = data.frame(matrix(NA,nrow = 0, ncol = 31))
  
  inner_processor = function(row, df) {
    
    # base case
    if(length(row) <= 0) {
      
      return(df)
      
    }
    
    num_bins = parse_number(unlist(strsplit(colnames(row)[1], '_'))[2])
    
    image_data = unlist(strsplit(unlist(images[num_bins/2]),'(', fixed = T))
    
    num_image = parse_number(image_data[1])
    
    num_round = which(order == num_bins)
    
    histogram = as.numeric(unlist(row[1:num_bins]))
    
    peak = max(histogram)
    
    num_on_peak = sum(histogram == peak)
    
    no_dots = parse_number(image_data[2])
    
    correct_bin = ceiling(no_dots/(1000/num_bins))
    
    correct_bin_conf = histogram[correct_bin]
    
    is_hit = as.numeric(histogram[correct_bin] == peak) / num_on_peak
    
    histogram = c(histogram, rep(NA,20-length(histogram)))
    
    df[nrow(df)+1,] = c(ID, num_round,num_bins, num_image, peak, num_on_peak, 
                        correct_bin, correct_bin_conf, is_hit, NA, NA, histogram)
    
    # recursive call to inner_processor
    return(inner_processor(row = row[-c(1:num_bins)], df))
  }
  
  # call to inner_processor
  return(inner_processor(row = participant_row, df = current))
}



## processing all rows

for(i in 1:nrow(raw_data)){
  
  participant = raw_data[i,!is.na(raw_data[i,])]
  
  processed_row = processor(participant_row = participant, order =  bin_order[i,], ID =  IDs[i], images =  rand_image[i,])
  
  EDH[(nrow(EDH)+1):(nrow(EDH)+nrow(processed_row)),] = processed_row
}


# converting quantitative columns into numeric

for(i in 3:ncol(EDH)){
  
  EDH[,i] = as.numeric(EDH[,i])
}


## calculating overprecision

bin = 2

while(bin <= 20){
  
  mean_hit = mean(EDH[EDH$Bins == bin, 9])
  
  EDH[EDH$Bins == bin, 10] = round(EDH[EDH$Bins == bin, 5]/100 - mean_hit, 3)
  
  bin = bin + 2
}


## calculating QSR

for(i in c(1:nrow(EDH))){
  
  wrong_choices = sum((EDH[i,12:(11 + EDH$Bins[i])][-c(EDH$Corr_Bin[i])]/100)^2)
  
  EDH$QSR[i] = 1 + EDH$Conf_Corr[i]/50 - wrong_choices
  
}

EDH$QSR = round(EDH$QSR / max(EDH$QSR), 3)


# converting qualitative columns into factor

EDH$ID = as.factor(EDH$ID)

EDH$Round = as.factor(EDH$Round)



### executing preregistered analysis: a linear regression at the level of the round (5 observations per participant) 
### with fixed effects for subject, in which the number of bins (B) is the independent variable.  
### In order to accommodate the possibility that the number of bins bears a curvilinear relationship with overprecision, we will also include 1- (1/B) as an independent variable. 

EDH$DecBins = 1 - (1/EDH$Bins)

attach(EDH)

fit = lm(Overprecision~Bins+DecBins+factor(ID))

summary(fit)

##Obtaining descriptives, simple effects, and effect sizes
mean(EDH$Peak)
mean(EDH$Hit)

EDH1rpp <- aggregate(Peak~ID,EDH,mean)
t.test(EDH1rpp$Peak, mu = 32.9)
(mean(EDH1rpp$Peak) - 32.9)/(sd(EDH1rpp$Peak))

#select only the 2-bin rounds
EDH2bin <- subset(EDH,EDH$Bins==2)
EDH2binrpp <- aggregate(Peak~ID,EDH2bin,mean) #average within individual
t.test(EDH2binrpp$Peak, mu = mean(EDH2bin$Hit)*100)
(mean(EDH2binrpp$Peak) - 81.2)
(mean(EDH2binrpp$Peak) - 81.2)/(sd(EDH1rpp$Peak))

#select only the 20-bin rounds
EDH20bin <- subset(EDH,EDH$Bins==20)
mean(EDH20bin$Hit)
EDH20binrpp <- aggregate(Peak~ID,EDH20bin,mean) #average within individual
t.test(EDH20binrpp$Peak, mu = mean(EDH20bin$Hit)*100)
(mean(EDH20binrpp$Peak) - 17.8)
(mean(EDH20binrpp$Peak) - 17.8)/(sd(EDH1rpp$Peak))

### Plotting and visualizing results
aggregate(Overprecision~Bins,EDH,mean)
hitrates <- aggregate(Hit~Bins,EDH,mean)
hitrates$Hit <- hitrates$Hit*100

#this violin plot shows peak probability by binning condition 
ggplot2::ggplot(EDH,aes(x=as.factor(Bins),y=Overprecision))+ #defines x, y variables
  geom_violin()  +  #makes it a violin plot!
  stat_summary(fun=mean,geom="point",shape=16,size=2,position=position_dodge(width=.9)) +  #adds dots at the mean
  stat_summary(fun.data=mean_se,geom="errorbar",position=position_dodge(width=.9),width = .3) +#adds error bars
  ylab("Confidence in the focal bin")+              #y-axis label
  xlab("Number of bins") +         #x-axis label  
  scale_x_discrete(labels=c("2","4","6","8","10","12","14","16","18","20")) +
  geom_point(data=hitrates,shape=4,color="red",size=3,aes(x=as.factor(Bins),y=Hits)) 

ggplot2::ggplot(EDH,aes(x=as.factor(Bins),y=Peak))+ #defines x, y variables
  geom_violin()  +  #makes it a violin plot!
  stat_summary(fun.y=mean,geom="point",shape=16,size=2,position=position_dodge(width=.9)) +  #adds dots at the mean
  stat_summary(fun.data=mean_se,geom="errorbar",position=position_dodge(width=.9),width = .3) +#adds error bars
  ylab("Confidence in the focal bin")+              #y-axis label
  xlab("Number of bins") +         #x-axis label  
  scale_x_discrete(labels=c("2","4","6","8","10","12","14","16","18","20")) +
  geom_point(data=hitrates,shape=4,color="red",size=3,aes(x=as.factor(Bins),y=Hit)) 


##Draw the calibration curve
#make a key col with response ID&round
EDH$IDr <- paste(EDH$ID,EDH$Round)

#take just the columns with confidence numbers
EDHconf <- EDH[, c(12:31,33)]

#then melt it all down so there's one number per row in the dataframe Edh-Confidence-Long
ECL <- melt(EDHconf,id.vars=c("IDr"))
ECL$Confidence <- ECL$value/100

#then drop the NAs
ECL <- ECL[!is.na(ECL$Confidence), ]

##bring in hit rates
hits <- EDH[, c(33,7)] #create a dataframe with correct bin and IDr
ECL <- merge(ECL,hits,by="IDr") #merge it with ECL
ECL$BinNo <- as.numeric(substring(ECL$variable,4)) # get a column with BinNo in ECL
ECL$Correct <- ifelse(ECL$BinNo==ECL$Corr_Bin,1,0) #Designate a correct bin when the bin no matches the correct bin

#bin numbers into categories:
ECL$RspCat <- round(ECL$Confidence, digits=1)
summary(ECL$RspCat)
aggregate(ECL$Confidence~ECL$RspCat, FUN=mean)
aggregate(ECL$Correct~ECL$RspCat, FUN=mean)

ECL.lines1 <- aggregate(Confidence~RspCat,ECL,mean)
ECL.lines2 <- aggregate(Correct~RspCat,ECL,mean)
stderr <- function(x) sqrt(var(x,na.rm=TRUE)/length(na.omit(x))) #define standard error function
ECL.lines.se <- aggregate(Correct~RspCat,ECL,stderr)
colnames(ECL.lines.se)[colnames(ECL.lines.se)=="Correct"] <- "CorrSE" #rename se
ECL.lines <- merge(ECL.lines1,ECL.lines2,by="RspCat")
ECL.lines <- merge(ECL.lines,ECL.lines.se,by="RspCat")

#plot the lines of confidence vs. accuracy across all bins 
ggplot(data=ECL.lines,aes(x=Confidence,y=Correct))+ #defines x, y, and color variable
  geom_line(size=1.2,colour="red")  +                      #sets line width
  geom_errorbar(aes(ymin=Correct-CorrSE, ymax=Correct+CorrSE), width=.02) + #adds error bars
  ylab("Accuracy")+              #y-axis label
  xlab("Confidence")  +        #x-axis label 
  geom_line(data = ECL.lines, aes(x = RspCat, y = RspCat), color = "blue") 


## exporting cleaned data
write.table(EDH, file = 'EDH Cleaned.csv', sep = ',', row.names = F)
