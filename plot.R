library(dplyr)
library(ggplot2)
library(readxl)
library(lubridate)
library(scales)

# load data ----------------------------------------------------------------

data <- read_excel("result/cht_people_data.xlsx")


# plot --------------------------------------------------------------------

data %>%
  filter(date_time %within% as.interval(days(1), as.POSIXct("2015-11-19"))) %>%
  ggplot(., aes(x=date_time, y=POPULATION)) +
  geom_line() +
  facet_wrap(~id) +
  scale_x_datetime( breaks=("2 hour"), minor_breaks=("1 hour"), labels=date_format("%H:%M"))




