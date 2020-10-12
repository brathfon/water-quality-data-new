################################
# Use this R script to process the raw water quality, nutrient and bacterial information in the original database
# for a format ok for EPA and distribution to the web
# a) EPA WQX export
# b) Web export
# The script inputs 4 files - 2 data files (wq, nutrient) and 2 template files (EPA and webexport)
# The script eliminates duplicate nutrient samples, and identifies which samples are less than the MDLs
# Line 118 identifies which column numbers the appropriate variables are - which is important
# The script also tests to make sure the number of WQ samples = the number of nutrient samples

#Functions
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

"%w%" <- function(x, y) x[!x %in% y] #--  x without y

#Libraries
library("chron")
library("dplyr")
library(reshape)
library(plyr)
library(dplyr)
library("dplyr", lib.loc="~/R/win-library/3.2")
library(ggplot2)
library(xlsx)
library(spacetime)
library(scales)
#library(readxls)

#Set working directory
setwd("C:\\Users\\falinski\\Dropbox\\2. TNC\\Hui O Ka Wai Ola Database\\EPA WQX Upload\\March 2018")

#Download and merge data

#WQ Data #Remember to remove formulas and paste as numbers
wqdata<-read.xlsx("field_data_master_WQXv0218_v2.xlsx", sheetName="DataEntry_WQ", header=T, row.names=NULL)
#wqdata <- read_excel("C:/Users/falinski/Dropbox/2. TNC/Hui O Ka Wai Ola Database/EPA WQX Upload/June 2017/field_data_master_WQXv2.xlsx", 
 #                    sheet = "DataEntry_WQ")
#Nutrient Data
nutdata<-read.xlsx("Master_Nutrient_wqxMar18.xlsx", sheetName="NUTRIENT", header=T, row.names=NULL)

#TSS Data
#Currently N/A

#WQX
#Template for WQX
wqxdata<-read.xlsx("template_test_wqx.xlsx", sheetName="Template", header=T, row.names=NULL)
wqxdata$Monitoring.Location.ID<-as.character(wqxdata$Monitoring.Location.ID)

#Eliminate unneeded columns
wqxdata<-wqxdata[-c(32:40)]

# Sitenames ----------------------------------------------------------

#Sitenames
sitenameso<-c("Honolua",
              "Fleming N",
              "Oneloa",
              "Kapalua Bay",
              "Napili",
              "Ka'opala",
              "Kahana Village",
              "Pohaku",
              "Kaanapali Shores",
              "Airport Beach",
              "Canoe Beach",
              "Wahikuli",
              "505 Front Street",
              "Lindsey Hale",
              "Lahaina Town",
              "Makila Point",
              "Launiupoko",
              "Olowalu shore",
              "Peter Martin Hale",
              "Camp Olowalu",
              "Mile Marker 14",
              "Ukumehame Beach",
              "Papalaua",
              "Papalaua Pali")


# Data Transformations ----------------------------------------------------


#Data transformations
wqdata$SampleID<-as.character(wqdata$SampleID)
wqdata$Station<-as.character(wqdata$Station)
wqdata$Turb<-round(as.numeric(paste(wqdata$Turb)), digits=2)
wqdata$pH<-as.numeric(paste(wqdata$pH))



#Remove duplicates in nutrient data
nutdata_nodups<-nutdata %>% filter(Dup=="no")
#nutdata_nodups[441:464,]<-NA #Just for now to make the datasets equal length


#Identify nutrient values that were below detection limit
nutdata_nodups_MDL<-nutdata_nodups %>% filter(NNN=="<0.1"|Ammonia=="<1.5")
NNN_MDL<-which(nutdata_nodups$NNN=="<0.1")
Ammonia_MDL<-which(nutdata_nodups$Ammonia=="<1.5")
nutdata_nodups$NNN<-as.numeric(paste(nutdata_nodups$NNN))
nutdata_nodups$Ammonia<-as.numeric(paste(nutdata_nodups$Ammonia))

#Remove the results from the values that are below DL
nutdata_nodups_MDL<-nutdata_nodups
nutdata_nodups_MDL$Ammonia[Ammonia_MDL]<-NA
nutdata_nodups_MDL$NNN[NNN_MDL]<-NA

#Create two new columns to show where the flags are
nutdata_nodups_MDL$NNNflag<-""
nutdata_nodups_MDL$Ammoniaflag<-""

#Populate columns
nutdata_nodups_MDL$Ammoniaflag[Ammonia_MDL]<-"<"
nutdata_nodups_MDL$NNNflag[NNN_MDL]<-"<"

#Small kine analysis playing
#foo2<-wqdata %>% summarize(avg = mean(Turb, na.rm=TRUE)) %>% print()

#bind.rows(y,z) and bind.cols(y,z)


# WQX Initialize ----------------------------------------------------------------


#>>>>>>>>>>>>> Trying to get at each dataset: #filter is for rows, select is for columns


#For each dataset for each parameter, pull down appropriate information
# Session_num<-28
# 
# wqsubset<-wqdata %>% filter(Session==Session_num)
# wqsubsetnut<-nutdata_nodups_MDL %>% filter(Session==Session_num)


#Check to make sure you have a nutrient sample for each field sample
wqsubset_n<-nrow(wqsubset)
wqsubsetnut_n<-nrow(wqsubsetnut)

Session_first<-28
Session_last<-30

#History:
#June 2017- 1-23
#Sept 2017- 24-26
#Nov 2017- 27

for (Session_num in Session_first:Session_last){
  wqsubset<-wqdata %>% filter(Session==Session_num)
  wqsubsetnut<-nutdata_nodups_MDL %>% filter(Session==Session_num)
  wqsubset_n<-nrow(wqsubset)
  wqsubsetnut_n<-nrow(wqsubsetnut)
if(wqsubsetnut_n != wqsubset_n ) {
  print(paste("Number of samples not equal in Session", as.character(Session_num)))
  #stop()
}
} #Session 23 not ok right now... 

#if(wqsubset_n == 0 | wqsubsetnut_n == 0){stop()}

#Create the codes to be attached to each sample_ID
DL<-c(1.5, 1.5, 1.5, 1.5, 0.1, 1.5) #These are the MDLs
tags<-c("T", "DO", "DOp", "pH", "S", "TB", "TN", "TP", "PO4", "Si", "NNN", "NH4")
#tag_num<-c(27, 29, 30, 31, 28, 35, 11, 12, 13, 14, 15, 16) #These comes from the columns in the data sheet
tag_num<-c(29, 31, 32, 33, 30, 37, #Water quality data file, col numbers
           11, 12, 13, 14, 15, 16) #Nutrient data file

#Initialize the matrix with the WQX template
wqexportALL<-wqxdata[FALSE,]

#Begin very big for loop here:
for (Session_num in Session_first:Session_last) {
  wqsubset<-wqdata %>% filter(Session==Session_num)
  wqsubsetnut<-nutdata_nodups_MDL %>% filter(Session==Session_num)
  wqsubset_n<-nrow(wqsubset)
  wqsubsetnut_n<-nrow(wqsubsetnut)

#Create blank data frame for final data
wqexport<-wqxdata[FALSE,]



# WQX Data Input ----------------------------------------------------------------

#For each data collection session, paste the data for each parameter along with its WQX info
for (bar in 1:12) {
  # Input the field parameters
  if (bar<7){
    temp=wqxdata[FALSE,]
    vals<-which(!is.na(wqsubset[,tag_num[bar]])) #If a parameter doesn't have a value, eliminate that line
    if (length(vals)==0) {next}
    temp[vals,1]<-""
    temp[vals,2]<-wqsubset$Station[vals]
    temp[vals,3]<-paste(wqsubset$SampleID[vals], rep(tags[bar], length(vals)), sep="") #Create unique sample number for variable
    temp[vals,18]<-wqsubset[vals,tag_num[bar]] #Add Temp values to Result
  
    temp[vals,6]<-format(wqsubset$Date[vals], '%Y-%m-%d')
    temp[vals,7]<-format(wqsubset$Time[vals],'%H:%M:%S')}
  
  # Input the nutrient data
  else {
    temp=wqxdata[FALSE,]
    vals<-1:wqsubsetnut_n
    temp[vals,1]<-""
    temp[,2]<-as.character(wqsubsetnut$Station)
    temp[,3]<-paste(as.character(wqsubsetnut$SampleID), rep(tags[bar], wqsubset_n), sep="") #Create unique sample number for variable
    temp[,18]<-round(wqsubsetnut[,tag_num[bar]], digits=2) #Add Result values for each parameter
    temp[,6]<-format(wqsubsetnut$Date, '%Y-%m-%d')
    temp[,7]<-format(wqsubset$Time,'%H:%M:%S')
    }
  
  #Use the info for each parameter to populate the table.  The template file for wqx is the basis for this.
  temp[vals,1]<-"HUI_PCHEM" #HUI_PCHEM
  temp[vals,4]<-as.character(wqxdata$Activity.Type[bar])
  temp[vals,5]<-as.character(wqxdata$Activity.Media.Name[bar])
  temp[vals,8]<-as.character(wqxdata$Activity.Start.Time.Zone[bar])
  temp[vals,11]<-as.character(wqxdata$Sample.Collection.Method.ID[bar])
  temp[vals,12]<-as.character(wqxdata$Sample.Collection.Equipment.Name[bar])
  temp[vals,15]<-as.character(wqxdata$Characteristic.Name[bar])
  temp[vals,16]<-as.character(wqxdata$Method.Speciation[bar])
  #temp[,18]<-"ResultValue"
  temp[vals,19]<-as.character(wqxdata$Result.Unit[bar])
  temp[vals,21]<-as.character(wqxdata$Result.Sample.Fraction[bar])
  temp[vals,22]<-as.character(wqxdata$Result.Status.ID[bar])
  temp[vals,24]<-as.character(wqxdata$Result.Value.Type[bar])
  temp[vals,25]<-as.character(wqxdata$Result.Analytical.Method.ID[bar])
  temp[vals,26]<-as.character(wqxdata$Result.Analytical.Method.Context[bar])#APHA
  temp[vals,c(17,28,30)]<-""
  
  
  #Add in detection limits for nuts below the limit
  if (bar==12) {
    flag<-which(wqsubsetnut$Ammoniaflag=="<")
    temp[flag,17]<-"Not Detected"
    temp[flag,28]<-"Method Detection Level"
    temp[flag,29]<-1.5
    temp[flag,30]<-"ug/l"
  }

  if (bar==11) {
    flag<-which(wqsubsetnut$NNNflag=="<")
    temp[flag,17]<-"Not Detected"
    temp[flag,28]<-"Method Detection Level"
    temp[flag,29]<-0.1
    temp[flag,30]<-"ug/l"
  }
  
  #Attach new data to wqexport
  wqexport<-rbind(wqexport,temp)
  
  if(bar<length(tags))
  #Delete temp so it can be used again
  {rm(temp)}
  
  
}






filewqx<-paste("wqexport_", Sys.Date(), "_", as.character(Session_num), ".xlsx", sep="")

#Remove some NAs
wqexport[is.na(wqexport)]<-""

wqexportALL<-rbind(wqexportALL,wqexport)

#write.xlsx(wqexport, filewqx, sheetName="WQXExport")

} #End For Loop for Session_num

#wqexport<-wqxdata[FALSE,]

# WQX Write File ----------------------------------------------------------

filewqx<-paste("wqexport_", Sys.Date(), "Session28_30",  ".xlsx", sep="")
write.xlsx(wqexportALL, filewqx, sheetName="WQXExport")




# Website -----------------------------------------------------------------

#Export Data for Website

#Template for Website
webdatatemplate<-read.xlsx("Huidata_website.xlsx", sheetName="Template", header=T, row.names=NULL)


webtemp<-webdatatemplate[FALSE,]
webtemp[1:nrow(wqdata),]<-NA
webtemp$SampleID<-wqdata$SampleID
webtemp$Station<-wqdata$Station
webtemp$Date<-wqdata$Date
webtemp$SiteName<-wqdata$SiteName
webtemp$Session<-wqdata$Session
webtemp$Time<-format(wqdata$Time, "%H:%M")
webtemp$Temp<-round(wqdata$Temp,digits=2)
webtemp$Salinity<-round(wqdata$Salinity,digits=2)
webtemp$DO<-round(wqdata$DO, digits=2)
webtemp$DO_sat<-round(wqdata$DO., digits=2)
webtemp$pH<-round(wqdata$pH, digits=2)
webtemp$Turbidity<-round(wqdata$Turb, digits=2)


#Nuts
webtemp$TotalN<-round(nutdata_nodups$TotalN,digits=2)
webtemp$TotalP<-round(nutdata_nodups$TotalP, digits=2)
webtemp$Phosphate<-round(nutdata_nodups$Phosphate, digits=2)
webtemp$Silicate<-round(nutdata_nodups$Silicate, digits=2)
webtemp$NNN<-round(nutdata_nodups_MDL$NNN, digits=2)
webtemp$NH4<-round(nutdata_nodups_MDL$Ammonia,digits=2)

#Add qualifiers
webtemp$NNN_<-""
webtemp$NNN_[NNN_MDL]<-"<"
webtemp$NH4_<-""
webtemp$NH4_[Ammonia_MDL]<-"<"

#Write File
write.xlsx(webtemp, paste("webexport_", as.character(Sys.Date()), ".xlsx", sep=""), sheetName="DATA")
