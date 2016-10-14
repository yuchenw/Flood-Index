### This script calculates FRI based on the value of simdaily

### This script creates a function to read all sensitivity results

# Clear working directory
rm(list = ls())

# Set working directory to import functions
setwd("F:/ClimateJustice/YuChen/ClimateRuns")

# Load packages
library(dplyr)
library(lubridate)

# Create a vector to include all names of 30 scenarios
s_vec1 <- seq(0, 5, 1)
s_vec2 <- c("T+20P", "T+10P", "T0P", "T-10P", "T-20P")
s_vec <- as.vector(outer(s_vec1, s_vec2, paste0))
o_vec <- sapply(s_vec, substr, start = 1, stop = 1)
s_vec <- s_vec[order(o_vec)]

### Load all data

# Load the function
source("Function_readSimDaily.R")
source("Function_Flood_Index.R")

# Set working directory to import SimDaily data
setwd("F:/ClimateJustice/FloodHazardIndex/XinXu_files/Huron_SWAT_manual_calibration/ClimateStressTest - Sensitivity")

# Use lapply to real all data
all_list <- lapply(s_vec, readSimDaily)
names(all_list) <- s_vec

# Set the working directory to save output files
setwd("F:/ClimateJustice/YuChen/ClimateRuns")

### Remove water year from 2024
all_list2 <- lapply(all_list, lapply, function(input) input <- input %>% 
                      filter(Wateryear >= 2025 & Wateryear <= 2075))

# Read baseline condition
baseline <- read.table("F:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/0T0P_Qbl.txt", 
                       header = TRUE)

### Calculate Flood Exceedance Probability

### Calculate the index
for (scenario in s_vec){
  # Select a scenario as a list
  sc_list <- all_list2[[scenario]]
  
  # Use sapply to calculate the indices
  FD_result <- sapply(1:57, function(i) FD_Index(sc_list[[i]], threshold = baseline$Qbl[i]))
  FM_result <- sapply(1:57, function(i) FM_Index(sc_list[[i]], threshold = baseline$Qbl[i]))
  FF_result <- sapply(1:57, function(i) FF_Index(sc_list[[i]], threshold = baseline$Qbl[i]))
  FEP_result <- sapply(1:57, function(i) FEP_Index(sc_list[[i]], threshold = baseline$Qbl[i]))
  
  # Create a temp data frame to save the result
  temp_df <- data.frame(subNo = 1:57, FD = FD_result, FM = FM_result, 
                        FF = FF_result, FEP = FEP_result, Qbl = baseline$Qbl,
                        stringsAsFactors = FALSE)
  
  # Save a csv file for each scenario
  write.csv(temp_df, paste0("F:/ClimateJustice/YuChen/ClimateRuns/sensitivity_re2/FFI_", 
                            scenario, ".csv"), row.names = FALSE)
}