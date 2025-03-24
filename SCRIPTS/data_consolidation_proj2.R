###### Initial Data Consolidation
dataMain<-read.csv("approval_ratings_clean.csv")
dataMain$Date<-as.Date(dataMain$Date)
GDP<-read.csv("GDPC1.csv")
GDP$observation_date<-as.Date(GDP$observation_date)
unemployment<-read.csv("UNRATE.csv")
unemployment$observation_date<-as.Date(unemployment$observation_date)
CPI<-read.csv("MED.csv")
CPI$observation_date<-as.Date(CPI$observation_date)

congressSupport<-read.csv("congressSupportByParty.csv")
congressSupport$Year<-paste(congressSupport$Year, "-01-01", sep = "")
congressSupport$Year<-as.Date(congressSupport$Year)

library(ggplot2)
library(dplyr)
library(patchwork)
CPI$CPI_change<-CPI$MEDCPIM158SFRBCLE
CPI<-CPI[,c(1,3)]

# Graphics 
plot1<-ggplot()+
  geom_line(data = dataMain, aes(x = Date, y = Approval))+
  labs(title = "Presidential approval ratings vs. Unemployment", x = "")
plot2<-ggplot()+
  geom_line(data = unemployment, aes(x = observation_date, y = UNRATE))+
  labs(x = "Date", y = "Pct. Unemployed")
plot1 / plot2

###### Further Data Consolidation

## Format the date in YYYY/MM format
dataMain$Date<-format(dataMain$Date, "%Y/%m")
GDP$observation_date<-format(GDP$observation_date, "%Y/%m")
unemployment$observation_date<-format(unemployment$observation_date, "%Y/%m")
CPI$observation_date<-format(CPI$observation_date, "%Y/%m")
congressSupport$Year<-format(congressSupport$Year, "%Y/%m")

# Renaming columns in preparation for merge
names(GDP)<-c("Date", "GDP")
names(unemployment)<-c("Date","UnemploymentRate")
names(congressSupport)<-c("President","Date","Chamber","ChamberParty","PctVotes")
congressSupport<-congressSupport[congressSupport$ChamberParty!="Southern Democrats",] # Remove Southern Democrats due to lack of data
congressSupport$ChamberParty<-ifelse(congressSupport$ChamberParty=="All Democrats", "Democrat", "Republican") # Match PrezParty column
names(CPI)<-c("Date","CPI_Change")

# Create "PrezParty" column for president's party
dataMain$PrezParty<-ifelse(dataMain$President=="Truman" | 
                             dataMain$President=="Kennedy" |
                             dataMain$President=="Johnson" |
                             dataMain$President=="Carter" |
                             dataMain$President=="Clinton" |
                             dataMain$President=="Obama" |
                             dataMain$President=="Biden", "Democrat",
                           "Republican")

# Grouping approval ratings by taking the average approval rating in a month 
dataMain2<-dataMain%>%
  group_by(Date, President)%>%
  reframe(Approval = round(mean(Approval), 4))
# Remove January rows for newly-elected presidents since they're only in office for 10 days + inauguration boost
dataMain2<-dataMain2[c(-855, -794, -697, -504, -297, -236),]

# Re-add party column
dataMain2$PrezParty<-ifelse(dataMain2$President=="Truman" | 
                             dataMain2$President=="Kennedy" |
                             dataMain2$President=="Johnson" |
                             dataMain2$President=="Carter" |
                             dataMain2$President=="Clinton" |
                             dataMain2$President=="Obama" |
                             dataMain2$President=="Biden", "Democrat",
                           "Republican")

#Adjust CongressSupport so that it only includes figures for the president's own party
congressSupport$PrezParty<-ifelse(congressSupport$President=="Truman" | 
                             congressSupport$President=="Kennedy" |
                             congressSupport$President=="Johnson" |
                             congressSupport$President=="Carter" |
                             congressSupport$President=="Clinton" |
                             congressSupport$President=="Obama" |
                             congressSupport$President=="Biden", "Democrat",
                           "Republican")

# Only Senate support due to Senate being the primary arbiter of which bills become law
congressSupport2<-congressSupport%>%
  filter(ChamberParty == PrezParty)%>%
  filter(Chamber=="Senate")

# Add months
library(padr)
library(tidyr)
congressSupport2$Date<-paste(congressSupport2$Date, "/01", sep = "")
congressSupport2$Date<-as.Date(congressSupport2$Date)
congressSupport2<-pad(congressSupport2, interval = "month")
congressSupport2<-congressSupport2%>%
  fill(President)%>%
  fill(Chamber)%>%
  fill(ChamberParty)%>%
  fill(PctVotes)%>%
  fill(PrezParty)

congressSupport2<-congressSupport2[-(242:249),] #Remove Ford's rows in '74 before he became president in August
congressSupport2<-pad(congressSupport2, interval = "month")
congressSupport2<-congressSupport2%>%
  fill(President)%>%
  fill(Chamber)%>%
  fill(ChamberParty)%>%
  fill(PctVotes)%>%
  fill(PrezParty)

congressSupport2$Date<-format(congressSupport2$Date, "%Y/%m")

# Add Percent Change column for GDP
GDP2<-GDP%>%
  mutate(PrevQuarterGDP = c(GDP[1], GDP[1:311]))%>% # Assuming zero change for first quarter
  mutate(GDPchange = round(((GDP - PrevQuarterGDP) / PrevQuarterGDP )*100, 4)  )

GDP2<-GDP2[,-3]

# Final merge
allData<-full_join(dataMain2, CPI, by = "Date")
allData<-left_join(allData, congressSupport2, by = "Date")
allData<-allData[,c(-5,-9)]
allData<-full_join(allData, unemployment, by = "Date")
allData<-allData[-(884:945),]
allData<-full_join(allData, GDP2, by = "Date")
allData<-allData[-(884:906),]
allData<-allData[,c(-5,-8)]
names(allData)<-c("Date", "President", "Approval","PrezParty","Chamber","ChamberParty","UnemploymentRate","GDP", "GDPchange")
allDataGDPInferred<-allData%>%
  fill(GDP)%>% #Assuming that GDP remains stagnant within the quarter
  fill(GDPchange)

# Done!