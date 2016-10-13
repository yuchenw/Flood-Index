### This script calculates FRI based on the value of simdaily

### This script creates a function to read all sensitivity results

# Clear working directory
rm(list = ls())

# Set working directory for data import
setwd("G:/ClimateJustice/YuChen/ClimateRuns")

# Load packages
library(dplyr)
library(lubridate)
library(stringr)

# Create a vector to include all names of 30 scenarios
s_vec1 <- seq(0, 5, 1)
s_vec2 <- c("T+20P", "T+10P", "T0P", "T-10P", "T-20P")
s_vec <- as.vector(outer(s_vec1, s_vec2, paste0))
o_vec <- sapply(s_vec, substr, start = 1, stop = 1)
s_vec <- s_vec[order(o_vec)]

### Load all data

# Load the function
source("fun_readSimDaily.R")

# Set working directory for data import
setwd("G:/ClimateJustice/FloodHazardIndex/XinXu_files/Huron_SWAT_manual_calibration/ClimateStressTest - Sensitivity")

# Use lapply to real all data
all_list <- lapply(s_vec, readSimDaily)
names(all_list) <- s_vec

# Set the working directory back
setwd("G:/ClimateJustice/YuChen/ClimateRuns")

# Save R image
save.image("Sensitivity_Index.Rdata")

### Remove water year from 2024
all_list2 <- lapply(all_list, lapply, function(input) input <- input %>% 
                      filter(Wateryear >= 2025 & Wateryear <= 2075))

# Read baseline condition
baseline <- read.table("sensitivity_updated/FRI_bl_0T0P.txt", header = TRUE)

### Calculate Flood Exceedance Probability

# A function to calculate FEP for one subbasin
FEP <- function(input, threshold){
  totalnumber <- dim(input)[1]
  
  input1 <- input %>%
    filter(Flow >= threshold) %>%
    summarise(Number = n())
  
  answer <- (input1[1, 1]/totalnumber) * 100
  return(answer)
}

# A function to calculate the run length of each flood
run_len <- function(input, threshold){
  
  input1 <- input %>% mutate(Flood = ifelse(Flow >= threshold, 1, 0))
  len <- rle(input1$Flood)
  len_vec <- len$lengths[len$values == 1]
  return(len_vec)
}

# A function to calculate FE
FE <- function(input, threshold){
  len_vec <- run_len(input, threshold)
  
  Yearnum <- length(unique(input$Wateryear))
  
  answer <- length(len_vec)/Yearnum
  
  return(answer)
}


# A function to calculate DF
DF <- function(input, threshold){
  len_vec <- run_len(input, threshold)
  
  answer <- mean(len_vec)
  
  return(answer)
}

# A function to calculate QF
QF <- function(input, threshold){
  
  input1 <- input %>% 
    filter(Flow >= threshold) %>%
    summarise(Quantity = mean(Flow, na.rm = TRUE))
  
  return(input1$Quantity[1])
}

### Test

Sc <- all_list2[["0T0P"]]

DF(Sc[[22]], threshold = baseline$Qbl[22])
QF(Sc[[22]], threshold = baseline$Qbl[22])
FE(Sc[[22]], threshold = baseline$Qbl[22])
FEP(input = Sc[[22]], threshold = baseline$Qbl[22])

### Calculate the index
for (scenario in s_vec){
  # Select a scenario as a list
  sc_list <- all_list2[[scenario]]
  
  # Use sapply to calculate the indices
  DF_result <- sapply(1:57, function(i) DF(sc_list[[i]], threshold = baseline$Qbl[i]))
  QF_result <- sapply(1:57, function(i) QF(sc_list[[i]], threshold = baseline$Qbl[i]))
  FE_result <- sapply(1:57, function(i) FE(sc_list[[i]], threshold = baseline$Qbl[i]))
  FEP_result <- sapply(1:57, function(i) FEP(sc_list[[i]], threshold = baseline$Qbl[i]))
  
  # Create a temp data frame to save the result
  temp_df <- data.frame(subNo = 1:57, DFbl = DF_result, QFbl = QF_result, 
                        FEbl = FE_result, FEP = FEP_result, Qbl = baseline$Qbl,
                        stringsAsFactors = FALSE)
  
  # Save a csv file for each scenario
  write.csv(temp_df, paste0("sensitivity_re/fix_enddate_r/FRI_fixori_", scenario, ".csv"),
            row.names = FALSE)
}

### The same calculation, but change the QF function to adjust one
QF_ad <- function(input, threshold){
  
  input1 <- input %>%mutate(Flood = ifelse(Flow >= threshold, 1, 0))
  
  runlen <- rle(input1$Flood)
  value_original <- runlen$values
  runlen$values <- seq(1:length(runlen$values))
  
  input1 <- input1 %>% mutate(Group = inverse.rle(runlen))
  
  # Determine whether 0 or 1 means flood or not
  if (value_original[1] == 0){
    input2 <- input1 %>% filter(Group %% 2 == 0)
  } else {
    input2 <- input1 %>% filter(Group %% 2 == 1)
  }
  
  # Calculate the average quantity
  input3 <- input2 %>%
    group_by(Group) %>%
    summarise(Quantity1 = mean(Flow, na.rm = TRUE)) %>%
    ungroup() %>%
    summarise(Quantity2 = mean(Quantity1, na.rm = TRUE))
  
  return(input3$Quantity2[1])
}

# Test
QF_ad(Sc[[22]], threshold = baseline$Qbl[22])

### Calculate the index
for (scenario in s_vec){
  # Select a scenario as a list
  sc_list <- all_list2[[scenario]]
  
  # Use sapply to calculate the indices
  DF_result <- sapply(1:57, function(i) DF(sc_list[[i]], threshold = baseline$Qbl[i]))
  QF_result <- sapply(1:57, function(i) QF_ad(sc_list[[i]], threshold = baseline$Qbl[i]))
  FE_result <- sapply(1:57, function(i) FE(sc_list[[i]], threshold = baseline$Qbl[i]))
  FEP_result <- sapply(1:57, function(i) FEP(sc_list[[i]], threshold = baseline$Qbl[i]))
  
  # Create a temp data frame to save the result
  temp_df <- data.frame(subNo = 1:57, DFbl = DF_result, QFbl = QF_result, 
                        FEbl = FE_result, FEP = FEP_result, Qbl = baseline$Qbl,
                        stringsAsFactors = FALSE)
  
  # Save a csv file for each scenario
  write.csv(temp_df, paste0("sensitivity_re/fix_enddate_ad_r/FRI_fixori_ad_", scenario, ".csv"),
            row.names = FALSE)
}

### Design the second version of FRI function: Calculate year average
FEP2 <- function(input, threshold){
  input1 <- input %>%
    mutate(Flood= ifelse(Flow >= threshold, 1, 0))%>%
    group_by(Wateryear) %>%
    summarise(Totalday = sum(Flood)) %>%
    ungroup() %>%
    mutate(Prob = ifelse(leap_year(Wateryear), Totalday/366 * 100, Totalday/365 * 100))
  return(mean(input1$Prob))
}

DF2 <- function(input, threshold){
  DFnum <- sapply(unique(input$Wateryear), 
                  function(i) DF(input[input$Wateryear == i, ], threshold = threshold))
  DFnum[is.nan(DFnum)] <- 0
  return(mean(DFnum))
}

QF2 <- function(input, threshold){
  QFnum <- sapply(unique(input$Wateryear), 
                  function(i) QF_ad(input[input$Wateryear == i, ], threshold = threshold))
  QFnum[is.nan(QFnum)] <- 0
  return(mean(QFnum))
}

### Calculate the index
for (scenario in s_vec){
  # Select a scenario as a list
  sc_list <- all_list2[[scenario]]
  
  # Use sapply to calculate the indices
  DF_result <- sapply(1:57, function(i) DF2(sc_list[[i]], threshold = baseline$Qbl[i]))
  QF_result <- sapply(1:57, function(i) QF2(sc_list[[i]], threshold = baseline$Qbl[i]))
  FE_result <- sapply(1:57, function(i) FE(sc_list[[i]], threshold = baseline$Qbl[i]))
  FEP_result <- sapply(1:57, function(i) FEP2(sc_list[[i]], threshold = baseline$Qbl[i]))
  
  # Create a temp data frame to save the result
  temp_df <- data.frame(subNo = 1:57, DFbl = DF_result, QFbl = QF_result, 
                        FEbl = FE_result, FEP = FEP_result, Qbl = baseline$Qbl,
                        stringsAsFactors = FALSE)
  
  # Save a csv file for each scenario
  write.csv(temp_df, paste0("sensitivity_re/update_ad_r/FRI_update_ad_", scenario, ".csv"),
            row.names = FALSE)
}