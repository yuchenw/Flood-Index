### This script creates a function to read SimDaily data

# Load packages
library(dplyr)
library(lubridate)

## A function to read SimDaily data from one sub-basin
readSub <- function(sub, scenario){
  temp_df <- read.table(paste0(scenario, "/sim_daily", sub, ".dat"),
                        header = FALSE, skip = 1, stringsAsFactors = FALSE) %>% 
    select(1:3) %>%
    rename(Year = V1, Day = V2, Flow = V3) %>% # Change columne name
    mutate(Wateryear = ifelse(leap_year(Year), # Add water year
                              ifelse(Day >= 274, Year + 1, Year),
                              ifelse(Day >= 273, Year + 1, Year)))
  return(temp_df)
}

## A function to read all SimDaily data from one scenario
readSimDaily <- function(scenario){
  temp_list <- lapply(X = seq(1, 57, 1), FUN = readSub, scenario = scenario)
  return(temp_list)
}
