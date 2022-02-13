install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")

library(tidyverse)
library(lubridate)
library(ggplot2)

getwd()
setwd("Divvy_Annual_Data_csv")
q1_2020 <- read.csv("Divvy_Trips_2020_Q1.csv")
head(q1_2020)

table(q1_2020$member_casual)


# Add columns that list the date, month, day, and year of each ride.
#This will allow us to aggregate ride date for each month, day, or year. 
#Before comleting this operations we could only aggregate at the ride level.

q1_2020$date <- as.Date(q1_2020$started_at) 
q1_2020$month <- format(as.Date(q1_2020$date), "%m")
q1_2020$day <- format(as.Date(q1_2020$date), "%d")
q1_2020$year <- format(as.Date(q1_2020$date), "%Y")
q1_2020$day_of_week <- format(as.Date(q1_2020$date), "%A")

head(q1_2020$date)
head(q1_2020$day_of_week)

q1_2020$ride_length<- difftime(q1_2020$ended_at,q1_2020$started_at, units="secs")
head(q1_2020$ride_length)

str(q1_2020)

#Convert "ride_length" from Factor to numeric so we can run calculations on the data
is.factor(q1_2020$ride_length)
is.character(q1_2020$ride_length)
is.double(q1_2020$ride_length)

q1_2020$ride_length<-as.numeric(as.character(q1_2020$ride_length))
is.numeric(q1_2020$ride_length)

# Remove "bad" data
# The dataframe includes a few hundred entries when bikes were taken out of docks and checked for quality by Divvy or ride_length was negative
# We will create a new version of the dataframe (v2) since data is being removed:

table(q1_2020$start_station_name)
table(q1_2020$ride_length)

q1_2020_v2<-q1_2020[!(q1_2020$start_station_name == "HQ QR"|q1_2020$ride_length<0),]

# NEXT STEP: CONDUCT DESCRIPTIVE ANALYSIS
# Descriptive analysis on ride_length (all figures in SECONDS!!!)

mean(q1_2020_v2$ride_length)
median(q1_2020_v2$ride_length)
max(q1_2020_v2$ride_length)
min(q1_2020_v2$ride_length)
summary(q1_2020_v2$ride_length)

#Compare members and casual users by ride length
aggregate(q1_2020_v2$ride_length~q1_2020_v2$member_casual, FUN=mean)
aggregate(q1_2020_v2$ride_length~q1_2020_v2$member_casual, FUN=median)
aggregate(q1_2020_v2$ride_length~q1_2020_v2$member_casual, FUN=max)
aggregate(q1_2020_v2$ride_length~q1_2020_v2$member_casual, FUN=min)

# See the average ride time by each day for members vs casual users
aggregate(q1_2020_v2$ride_length~q1_2020_v2$member_casual+q1_2020_v2$day_of_week, FUN=mean)

#Notice that the days of the week are out of order. Let's fix that:

q1_2020_v2$day_of_week<- ordered(q1_2020_v2$day_of_week, levels=c("Sunday", "Monday", 
                      "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

aggregate(q1_2020_v2$ride_length~q1_2020_v2$member_casual+q1_2020_v2$day_of_week, FUN=mean)

# Analyze ridership data by type and weekday
q1_2020_v2 %>%  
  mutate(weekday=wday(started_at,label=TRUE)) %>% 
  group_by(member_casual,weekday) %>% 
  summarize(number_rides=n(),average=mean(ride_length)) %>% 
  arrange(member_casual,weekday)

# Let's visualize (build a PLOT) the number of rides by rider type
q1_2020_v2 %>%  
  mutate(weekday=wday(started_at,label=TRUE)) %>% 
  group_by(member_casual,weekday) %>% 
  summarize(number_rides=n(),average=mean(ride_length)) %>% 
  arrange(member_casual,weekday) %>% 
  ggplot(aes(x=weekday, y=number_rides, fill=member_casual)) +
  geom_col(position="dodge")

# Let's create a visualization for average duration
q1_2020_v2 %>%  
  mutate(weekday=wday(started_at,label=TRUE)) %>% 
  group_by(member_casual,weekday) %>% 
  summarize(number_rides=n(),average_duration=mean(ride_length)) %>% 
  arrange(member_casual,weekday) %>% 
  ggplot(aes(x=weekday, y=average_duration, fill=member_casual)) +
  geom_col(position="dodge")

counts <- aggregate(q1_2020_v2$ride_length ~ q1_2020_v2$member_casual + q1_2020_v2$day_of_week, FUN = mean)
write.csv(counts, file="/cloud/project/Divvy_Annual_Data_csv/ride_length.csv")
