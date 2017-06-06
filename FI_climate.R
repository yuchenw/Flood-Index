### This script calculates the four flood indices for the
### climate model test

### The first part of the code loads all the SimDaily data from
### all scenarios using the function "readSimDaily"
### After that, select the data for appropriate water years
### Finally, apply the FD_Index, FM_Index, FF_Index, and FEP_Index function
### to calculate flood duration, flood magnitude, flood frequency, and
### flood exceedance probability

### The SimDaily data of climate model scenarios are stored in the directory
### "G:/ClimateJustice/FloodHazardIndex/XinXu_files/Huron_SWAT_manual_calibration/ClimateStressTest - Sensitivity"
### See line 30-36 for their names.

### The scripts for R functions are stored in "G:/ClimateJustice/YuChen/ClimateRuns"

### The baselines' flow rate of two-year flood is stored in
### G:/ClimateJustice/YuChen/ClimateRuns/Qbl_data

### The final results are stored in "F:/ClimateJustice/YuChen/ClimateRuns/climate_re2"

# Clear working directory
rm(list = ls())

# Set working directory to import functions
setwd("G:/ClimateJustice/YuChen/ClimateRuns")

# Load packages
library(dplyr)
library(lubridate)

# Create a vector for all scenario
historical_vec <- c("GFDL_historical_WLEB_leapyears", "HadGEM_historical_WLEB_leapyears", 
                 "WLEB_CESM1_historical_WLEB_leapyears", "WLEB_CRCM_cgcm3_historical_WLEB_leapyears", 
                 "WLEB_RCM3_gfdl_historical_WLEB_leapyears")

future_vec <- c("GFDL_future_WLEB_leapyears", "HadGEM_future_WLEB_leapyears",
                "WLEB_CESM1_future_WLEB_leapyears", "WLEB_CRCM_cgcm3_future_WLEB_leapyears",
                "WLEB_RCM3_gfdl_future_WLEB_leapyears")

# Create a vector for model name
historical_name <- c("GFDL_historical", "HadGEM_historical", "CESM1_historical", "CRCM_historical", "RCM3_historical")

future_name <- c("GFDL_future", "HadGEM_future", "CESM1_future", "CRCM_future", "RCM3_future")


# Load the function
source("Function_readSimDaily.R")
source("Function_Flood_Index.R")

# Set working directory to import SimDaily data
setwd("G:/ClimateJustice/YuChen/ClimateRuns/climate_re")

# Use lapply to real all data
historical_list <- lapply(historical_vec, readSimDaily)
names(historical_list) <- historical_name

future_list <- lapply(future_vec, readSimDaily)
names(future_list) <- future_name


### Select water years
historical_list2 <- lapply(historical_list, lapply, function(input) input <- input %>% 
                      filter(Wateryear >= 1984 & Wateryear <= 1999))
future_list2 <- lapply(future_list, lapply, function(input) input <- input %>% 
                       filter(Wateryear >= 2045 & Wateryear <= 2060))

# Read baseline condition
GFDL_base <- read.table("G:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/RCM4_GFDL_Qbl.txt", 
                        header = TRUE)
HadGEM_base <- read.table("G:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/RCM4_HadGEM_Qbl.txt", 
                          header = TRUE)
CESM1_base <- read.table("G:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/CESM1_CAM5_Qbl.txt", 
                         header = TRUE)
CRCM_base <- read.table("G:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/CRCM_CGCM3_Qbl.txt", 
                        header = TRUE)
RCM3_base <- read.table("G:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/RCM3_GFDL_Qbl.txt", 
                        header = TRUE)


### Calculate the index

## GFDL Historical

GFDL_historical_list <- historical_list2[["GFDL_historical"]]

# Use sapply to calculate the indices
FD_GFDL_h_result <- sapply(1:57, function(i) FD_Index(GFDL_historical_list[[i]], 
                                                      threshold = GFDL_base$Qbl[i]))
FM_GFDL_h_result <- sapply(1:57, function(i) FM_Index(GFDL_historical_list[[i]], 
                                                      threshold = GFDL_base$Qbl[i]))
FF_GFDL_h_result <- sapply(1:57, function(i) FF_Index(GFDL_historical_list[[i]], 
                                                      threshold = GFDL_base$Qbl[i]))
FEP_GFDL_h_result <- sapply(1:57, function(i) FEP_Index(GFDL_historical_list[[i]], 
                                                        threshold = GFDL_base$Qbl[i]))

# Create a temp data frame to save the result
GFDL_FI_h_df <- data.frame(subNo = 1:57, 
                           FD = FD_GFDL_h_result, 
                           FM = FM_GFDL_h_result, 
                           FF = FF_GFDL_h_result, 
                           FEP = FEP_GFDL_h_result, 
                           Qbl = GFDL_base$Qbl,
                           stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(GFDL_FI_h_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/RCM4_GFDL_FI_h.csv", 
          row.names = FALSE)

## HadGEM historical

HadGEM_historical_list <- historical_list2[["HadGEM_historical"]]

# Use sapply to calculate the indices
FD_HadGEM_h_result <- sapply(1:57, function(i) FD_Index(HadGEM_historical_list[[i]], 
                                                        threshold = HadGEM_base$Qbl[i]))
FM_HadGEM_h_result <- sapply(1:57, function(i) FM_Index(HadGEM_historical_list[[i]], 
                                                        threshold = HadGEM_base$Qbl[i]))
FF_HadGEM_h_result <- sapply(1:57, function(i) FF_Index(HadGEM_historical_list[[i]], 
                                                        threshold = HadGEM_base$Qbl[i]))
FEP_HadGEM_h_result <- sapply(1:57, function(i) FEP_Index(HadGEM_historical_list[[i]], 
                                                        threshold = HadGEM_base$Qbl[i]))

# Create a temp data frame to save the result
HadGEM_FI_h_df <- data.frame(subNo = 1:57, 
                             FD = FD_HadGEM_h_result, 
                             FM = FM_HadGEM_h_result, 
                             FF = FF_HadGEM_h_result, 
                             FEP = FEP_HadGEM_h_result, 
                             Qbl = HadGEM_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(HadGEM_FI_h_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/RCM4_HadGEM_FI_h.csv", 
          row.names = FALSE)

## CESM1 historical

CESM1_historical_list <- historical_list2[["CESM1_historical"]]

# Use sapply to calculate the indices
FD_CESM1_h_result <- sapply(1:57, function(i) FD_Index(CESM1_historical_list[[i]], 
                                                       threshold = CESM1_base$Qbl[i]))
FM_CESM1_h_result <- sapply(1:57, function(i) FM_Index(CESM1_historical_list[[i]], 
                                                       threshold = CESM1_base$Qbl[i]))
FF_CESM1_h_result <- sapply(1:57, function(i) FF_Index(CESM1_historical_list[[i]], 
                                                       threshold = CESM1_base$Qbl[i]))
FEP_CESM1_h_result <- sapply(1:57, function(i) FEP_Index(CESM1_historical_list[[i]], 
                                                       threshold = CESM1_base$Qbl[i]))

# Create a temp data frame to save the result
CESM1_FI_h_df <- data.frame(subNo = 1:57, 
                              FD = FD_CESM1_h_result, 
                              FM = FM_CESM1_h_result, 
                              FF = FF_CESM1_h_result, 
                              FEP = FEP_CESM1_h_result, 
                              Qbl = CESM1_base$Qbl,
                              stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(CESM1_FI_h_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/CESM1_CAM5_FI_h.csv", 
          row.names = FALSE)

## CRCM historical

CRCM_historical_list <- historical_list2[["CRCM_historical"]]

# Use sapply to calculate the indices
FD_CRCM_h_result <- sapply(1:57, function(i) FD_Index(CRCM_historical_list[[i]], 
                                                  threshold = CRCM_base$Qbl[i]))
FM_CRCM_h_result <- sapply(1:57, function(i) FM_Index(CRCM_historical_list[[i]], 
                                                  threshold = CRCM_base$Qbl[i]))
FF_CRCM_h_result <- sapply(1:57, function(i) FF_Index(CRCM_historical_list[[i]], 
                                                 threshold = CRCM_base$Qbl[i]))
FEP_CRCM_h_result <- sapply(1:57, function(i) FEP_Index(CRCM_historical_list[[i]], 
                                                    threshold = CRCM_base$Qbl[i]))

# Create a temp data frame to save the result
CRCM_FI_h_df <- data.frame(subNo = 1:57, 
                             FD = FD_CRCM_h_result, 
                             FM = FM_CRCM_h_result, 
                             FF = FF_CRCM_h_result, 
                             FEP = FEP_CRCM_h_result, 
                             Qbl = CRCM_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(CRCM_FI_h_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/CRCM_CGCM3_FI_h.csv", 
          row.names = FALSE)

## RCM3 historical

RCM3_historical_list <- historical_list2[["RCM3_historical"]]

# Use sapply to calculate the indices
FD_RCM3_h_result <- sapply(1:57, function(i) FD_Index(RCM3_historical_list[[i]], 
                                                  threshold = RCM3_base$Qbl[i]))
FM_RCM3_h_result <- sapply(1:57, function(i) FM_Index(RCM3_historical_list[[i]], 
                                                  threshold = RCM3_base$Qbl[i]))
FF_RCM3_h_result <- sapply(1:57, function(i) FF_Index(RCM3_historical_list[[i]], 
                                                 threshold = RCM3_base$Qbl[i]))
FEP_RCM3_h_result <- sapply(1:57, function(i) FEP_Index(RCM3_historical_list[[i]], 
                                                    threshold = RCM3_base$Qbl[i]))

# Create a temp data frame to save the result
RCM3_FI_h_df <- data.frame(subNo = 1:57, 
                             FD = FD_RCM3_h_result, 
                             FM = FM_RCM3_h_result, 
                             FF = FF_RCM3_h_result, 
                             FEP = FEP_RCM3_h_result, 
                             Qbl = RCM3_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(RCM3_FI_h_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/RCM3_GFDL_FI_h.csv", row.names = FALSE)

## GFDL Future

GFDL_future_list <- future_list2[["GFDL_future"]]

# Use sapply to calculate the indices
FD_GFDL_f_result <- sapply(1:57, function(i) FD_Index(GFDL_future_list[[i]], 
                                                  threshold = GFDL_base$Qbl[i]))
FM_GFDL_f_result <- sapply(1:57, function(i) FM_Index(GFDL_future_list[[i]], 
                                                  threshold = GFDL_base$Qbl[i]))
FF_GFDL_f_result <- sapply(1:57, function(i) FF_Index(GFDL_future_list[[i]], 
                                                 threshold = GFDL_base$Qbl[i]))
FEP_GFDL_f_result <- sapply(1:57, function(i) FEP_Index(GFDL_future_list[[i]], 
                                                    threshold = GFDL_base$Qbl[i]))

# Create a temp data frame to save the result
GFDL_FI_f_df <- data.frame(subNo = 1:57, 
                             FD = FD_GFDL_f_result, 
                             FM = FM_GFDL_f_result, 
                             FF = FF_GFDL_f_result, 
                             FEP = FEP_GFDL_f_result, 
                             Qbl = GFDL_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(GFDL_FI_f_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/RCM4_GFDL_FI_f.csv", row.names = FALSE)

## HadGEM Future

HadGEM_future_list <- future_list2[["HadGEM_future"]]

# Use sapply to calculate the indices
FD_HadGEM_f_result <- sapply(1:57, function(i) FD_Index(HadGEM_future_list[[i]], 
                                                    threshold = HadGEM_base$Qbl[i]))
FM_HadGEM_f_result <- sapply(1:57, function(i) FM_Index(HadGEM_future_list[[i]], 
                                                    threshold = HadGEM_base$Qbl[i]))
FF_HadGEM_f_result <- sapply(1:57, function(i) FF_Index(HadGEM_future_list[[i]], 
                                                   threshold = HadGEM_base$Qbl[i]))
FEP_HadGEM_f_result <- sapply(1:57, function(i) FEP_Index(HadGEM_future_list[[i]], 
                                                      threshold = HadGEM_base$Qbl[i]))

# Create a temp data frame to save the result
HadGEM_FI_f_df <- data.frame(subNo = 1:57, 
                               FD = FD_HadGEM_f_result, 
                               FM = FM_HadGEM_f_result, 
                               FF = FF_HadGEM_f_result, 
                               FEP = FEP_HadGEM_f_result, 
                               Qbl = HadGEM_base$Qbl,
                               stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(HadGEM_FI_f_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/RCM4_HadGEM_FI_f.csv", row.names = FALSE)

## CESM1 Future

CESM1_future_list <- future_list2[["CESM1_future"]]

# Use sapply to calculate the indices
FD_CESM1_f_result <- sapply(1:57, function(i) FD_Index(CESM1_future_list[[i]], 
                                                   threshold = CESM1_base$Qbl[i]))
FM_CESM1_f_result <- sapply(1:57, function(i) FM_Index(CESM1_future_list[[i]], 
                                                   threshold = CESM1_base$Qbl[i]))
FF_CESM1_f_result <- sapply(1:57, function(i) FF_Index(CESM1_future_list[[i]], 
                                                  threshold = CESM1_base$Qbl[i]))
FEP_CESM1_f_result <- sapply(1:57, function(i) FEP_Index(CESM1_future_list[[i]], 
                                                     threshold = CESM1_base$Qbl[i]))

# Create a temp data frame to save the result
CESM1_FI_f_df <- data.frame(subNo = 1:57, 
                              FD = FD_CESM1_f_result, 
                              FM = FM_CESM1_f_result, 
                              FF = FF_CESM1_f_result, 
                              FEP = FEP_CESM1_f_result, 
                              Qbl = CESM1_base$Qbl,
                              stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(CESM1_FI_f_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/CESM1_CAM5_FI_f.csv", row.names = FALSE)

## CRCM Future

CRCM_future_list <- future_list2[["CRCM_future"]]

# Use sapply to calculate the indices
FD_CRCM_f_result <- sapply(1:57, function(i) FD_Index(CRCM_future_list[[i]], 
                                                  threshold = CRCM_base$Qbl[i]))
FM_CRCM_f_result <- sapply(1:57, function(i) FM_Index(CRCM_future_list[[i]], 
                                                  threshold = CRCM_base$Qbl[i]))
FF_CRCM_f_result <- sapply(1:57, function(i) FF_Index(CRCM_future_list[[i]], 
                                                 threshold = CRCM_base$Qbl[i]))
FEP_CRCM_f_result <- sapply(1:57, function(i) FEP_Index(CRCM_future_list[[i]], 
                                                    threshold = CRCM_base$Qbl[i]))

# Create a temp data frame to save the result
CRCM_FI_f_df <- data.frame(subNo = 1:57, 
                             FD = FD_CRCM_f_result, 
                             FM = FM_CRCM_f_result, 
                             FF = FF_CRCM_f_result, 
                             FEP = FEP_CRCM_f_result, 
                             Qbl = CRCM_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(CRCM_FI_f_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/CRCM_CGCM3_FI_f.csv", 
          row.names = FALSE)

## RCM3 Future

RCM3_future_list <- future_list2[["RCM3_future"]]

# Use sapply to calculate the indices
FD_RCM3_f_result <- sapply(1:57, function(i) FD_Index(RCM3_future_list[[i]], 
                                                  threshold = RCM3_base$Qbl[i]))
FM_RCM3_f_result <- sapply(1:57, function(i) FM_Index(RCM3_future_list[[i]], 
                                                  threshold = RCM3_base$Qbl[i]))
FF_RCM3_f_result <- sapply(1:57, function(i) FF_Index(RCM3_future_list[[i]], 
                                                 threshold = RCM3_base$Qbl[i]))
FEP_RCM3_f_result <- sapply(1:57, function(i) FEP_Index(RCM3_future_list[[i]], 
                                                    threshold = RCM3_base$Qbl[i]))

# Create a temp data frame to save the result
RCM3_FI_f_df <- data.frame(subNo = 1:57, 
                             FD = FD_RCM3_f_result, 
                             FM = FM_RCM3_f_result, 
                             FF = FF_RCM3_f_result, 
                             FEP = FEP_RCM3_f_result, 
                             Qbl = RCM3_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(RCM3_FI_f_df, "G:/ClimateJustice/YuChen/ClimateRuns/climate_re2/RCM3_GFDL_FI_f.csv", row.names = FALSE)
