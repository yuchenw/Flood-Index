### This script calculates FRI based on the value of simdaily

### This script creates a function to read all sensitivity results

# Clear working directory
rm(list = ls())

# Set working directory to import functions
setwd("F:/ClimateJustice/YuChen/ClimateRuns")

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
setwd("F:/ClimateJustice/YuChen/ClimateRuns/climate_re")

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
GFDL_base <- read.table("F:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/RCM4_GFDL_Qbl.txt", 
                        header = TRUE)
HadGEM_base <- read.table("F:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/RCM4_HadGEM_Qbl.txt", 
                          header = TRUE)
CESM1_base <- read.table("F:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/CESM1_CAM5_Qbl.txt", 
                         header = TRUE)
CRCM_base <- read.table("F:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/CRCM_CGCM3_Qbl.txt", 
                        header = TRUE)
RCM3_base <- read.table("F:/ClimateJustice/YuChen/ClimateRuns/Qbl_data/RCM3_GFDL_Qbl.txt", 
                        header = TRUE)


### Calculate the index

## GFDL Historical

GFDL_historical_list <- historical_list2[["GFDL_historical"]]

# Use sapply to calculate the indices
FD_GFDL_pp_result <- sapply(1:57, function(i) FD_Index(GFDL_historical_list[[i]], 
                                                  threshold = GFDL_base$Qbl[i]))
FM_GFDL_pp_result <- sapply(1:57, function(i) FM_Index(GFDL_historical_list[[i]], 
                                                  threshold = GFDL_base$Qbl[i]))
FF_GFDL_pp_result <- sapply(1:57, function(i) FF_Index(GFDL_historical_list[[i]], 
                                                 threshold = GFDL_base$Qbl[i]))
FEP_GFDL_pp_result <- sapply(1:57, function(i) FEP_Index(GFDL_historical_list[[i]], 
                                                    threshold = GFDL_base$Qbl[i]))

# Create a temp data frame to save the result
GFDL_FI_pp_df <- data.frame(subNo = 1:57, 
                            FD = FD_GFDL_pp_result, 
                            FM = FM_GFDL_pp_result, 
                            FF = FF_GFDL_pp_result, 
                            FEP = FEP_GFDL_pp_result, 
                            Qbl = GFDL_base$Qbl,
                            stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(GFDL_FI_pp_df, "F:/ClimateJustice/YuChen/ClimateRuns/climate_re2/GFDL_FI_pp_df.csv", 
          row.names = FALSE)

## HadGEM historical

HadGEM_historical_list <- historical_list2[["HadGEM_historical"]]

# Use sapply to calculate the indices
DF_HadGEM_pp_result <- sapply(1:57, function(i) DF2(HadGEM_historical_list[[i]], 
                                                    threshold = HadGEM_base$Qbl[i]))
QF_HadGEM_pp_result <- sapply(1:57, function(i) QF2(HadGEM_historical_list[[i]], 
                                                    threshold = HadGEM_base$Qbl[i]))
FE_HadGEM_pp_result <- sapply(1:57, function(i) FE(HadGEM_historical_list[[i]], 
                                                   threshold = HadGEM_base$Qbl[i]))
FEP_HadGEM_pp_result <- sapply(1:57, function(i) FEP2(HadGEM_historical_list[[i]], 
                                                      threshold = HadGEM_base$Qbl[i]))

# Create a temp data frame to save the result
HadGEM_FRI_pp_df <- data.frame(subNo = 1:57, 
                               DFbl = DF_HadGEM_pp_result, 
                               QFbl = QF_HadGEM_pp_result, 
                               FEbl = FE_HadGEM_pp_result, 
                               FEP = FEP_HadGEM_pp_result, 
                               Qbl = HadGEM_base$Qbl,
                               stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(HadGEM_FRI_pp_df, "climate_re/update_ad_r/HadGEM_FRI_pp_df.csv", row.names = FALSE)

## CESM1 historical

CESM1_historical_list <- historical_list2[["CESM1_historical"]]

# Use sapply to calculate the indices
DF_CESM1_pp_result <- sapply(1:57, function(i) DF2(CESM1_historical_list[[i]], 
                                                   threshold = CESM1_base$Qbl[i]))
QF_CESM1_pp_result <- sapply(1:57, function(i) QF2(CESM1_historical_list[[i]], 
                                                   threshold = CESM1_base$Qbl[i]))
FE_CESM1_pp_result <- sapply(1:57, function(i) FE(CESM1_historical_list[[i]], 
                                                  threshold = CESM1_base$Qbl[i]))
FEP_CESM1_pp_result <- sapply(1:57, function(i) FEP2(CESM1_historical_list[[i]], 
                                                     threshold = CESM1_base$Qbl[i]))

# Create a temp data frame to save the result
CESM1_FRI_pp_df <- data.frame(subNo = 1:57, 
                              DFbl = DF_CESM1_pp_result, 
                              QFbl = QF_CESM1_pp_result, 
                              FEbl = FE_CESM1_pp_result, 
                              FEP = FEP_CESM1_pp_result, 
                              Qbl = CESM1_base$Qbl,
                              stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(CESM1_FRI_pp_df, "climate_re/update_ad_r/CESM1_FRI_pp_df.csv", row.names = FALSE)

## CRCM historical

CRCM_historical_list <- historical_list2[["CRCM_historical"]]

# Use sapply to calculate the indices
DF_CRCM_pp_result <- sapply(1:57, function(i) DF2(CRCM_historical_list[[i]], 
                                                  threshold = CRCM_base$Qbl[i]))
QF_CRCM_pp_result <- sapply(1:57, function(i) QF2(CRCM_historical_list[[i]], 
                                                  threshold = CRCM_base$Qbl[i]))
FE_CRCM_pp_result <- sapply(1:57, function(i) FE(CRCM_historical_list[[i]], 
                                                 threshold = CRCM_base$Qbl[i]))
FEP_CRCM_pp_result <- sapply(1:57, function(i) FEP2(CRCM_historical_list[[i]], 
                                                    threshold = CRCM_base$Qbl[i]))

# Create a temp data frame to save the result
CRCM_FRI_pp_df <- data.frame(subNo = 1:57, 
                             DFbl = DF_CRCM_pp_result, 
                             QFbl = QF_CRCM_pp_result, 
                             FEbl = FE_CRCM_pp_result, 
                             FEP = FEP_CRCM_pp_result, 
                             Qbl = CRCM_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(CRCM_FRI_pp_df, "climate_re/update_ad_r/CRCM_FRI_pp_df.csv", row.names = FALSE)

## RCM3 historical

RCM3_historical_list <- historical_list2[["RCM3_historical"]]

# Use sapply to calculate the indices
DF_RCM3_pp_result <- sapply(1:57, function(i) DF2(RCM3_historical_list[[i]], 
                                                  threshold = RCM3_base$Qbl[i]))
QF_RCM3_pp_result <- sapply(1:57, function(i) QF2(RCM3_historical_list[[i]], 
                                                  threshold = RCM3_base$Qbl[i]))
FE_RCM3_pp_result <- sapply(1:57, function(i) FE(RCM3_historical_list[[i]], 
                                                 threshold = RCM3_base$Qbl[i]))
FEP_RCM3_pp_result <- sapply(1:57, function(i) FEP2(RCM3_historical_list[[i]], 
                                                    threshold = RCM3_base$Qbl[i]))

# Create a temp data frame to save the result
RCM3_FRI_pp_df <- data.frame(subNo = 1:57, 
                             DFbl = DF_RCM3_pp_result, 
                             QFbl = QF_RCM3_pp_result, 
                             FEbl = FE_RCM3_pp_result, 
                             FEP = FEP_RCM3_pp_result, 
                             Qbl = RCM3_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(RCM3_FRI_pp_df, "climate_re/update_ad_r/RCM3_FRI_pp_df.csv", row.names = FALSE)

## GFDL Future

GFDL_future_list <- future_list2[["GFDL_future"]]

# Use sapply to calculate the indices
DF_GFDL_fp_result <- sapply(1:57, function(i) DF2(GFDL_future_list[[i]], 
                                                  threshold = GFDL_base$Qbl[i]))
QF_GFDL_fp_result <- sapply(1:57, function(i) QF2(GFDL_future_list[[i]], 
                                                  threshold = GFDL_base$Qbl[i]))
FE_GFDL_fp_result <- sapply(1:57, function(i) FE(GFDL_future_list[[i]], 
                                                 threshold = GFDL_base$Qbl[i]))
FEP_GFDL_fp_result <- sapply(1:57, function(i) FEP2(GFDL_future_list[[i]], 
                                                    threshold = GFDL_base$Qbl[i]))

# Create a temp data frame to save the result
GFDL_FRI_fp_df <- data.frame(subNo = 1:57, 
                             DFbl = DF_GFDL_fp_result, 
                             QFbl = QF_GFDL_fp_result, 
                             FEbl = FE_GFDL_fp_result, 
                             FEP = FEP_GFDL_fp_result, 
                             Qbl = GFDL_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(GFDL_FRI_fp_df, "climate_re/update_ad_r/GFDL_FRI_fp_df.csv", row.names = FALSE)

## HadGEM Future

HadGEM_future_list <- future_list2[["HadGEM_future"]]

# Use sapply to calculate the indices
DF_HadGEM_fp_result <- sapply(1:57, function(i) DF2(HadGEM_future_list[[i]], 
                                                    threshold = HadGEM_base$Qbl[i]))
QF_HadGEM_fp_result <- sapply(1:57, function(i) QF2(HadGEM_future_list[[i]], 
                                                    threshold = HadGEM_base$Qbl[i]))
FE_HadGEM_fp_result <- sapply(1:57, function(i) FE(HadGEM_future_list[[i]], 
                                                   threshold = HadGEM_base$Qbl[i]))
FEP_HadGEM_fp_result <- sapply(1:57, function(i) FEP2(HadGEM_future_list[[i]], 
                                                      threshold = HadGEM_base$Qbl[i]))

# Create a temp data frame to save the result
HadGEM_FRI_fp_df <- data.frame(subNo = 1:57, 
                               DFbl = DF_HadGEM_fp_result, 
                               QFbl = QF_HadGEM_fp_result, 
                               FEbl = FE_HadGEM_fp_result, 
                               FEP = FEP_HadGEM_fp_result, 
                               Qbl = HadGEM_base$Qbl,
                               stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(HadGEM_FRI_fp_df, "climate_re/update_ad_r/HadGEM_FRI_fp_df.csv", row.names = FALSE)

## CESM1 Future

CESM1_future_list <- future_list2[["CESM1_future"]]

# Use sapply to calculate the indices
DF_CESM1_fp_result <- sapply(1:57, function(i) DF2(CESM1_future_list[[i]], 
                                                   threshold = CESM1_base$Qbl[i]))
QF_CESM1_fp_result <- sapply(1:57, function(i) QF2(CESM1_future_list[[i]], 
                                                   threshold = CESM1_base$Qbl[i]))
FE_CESM1_fp_result <- sapply(1:57, function(i) FE(CESM1_future_list[[i]], 
                                                  threshold = CESM1_base$Qbl[i]))
FEP_CESM1_fp_result <- sapply(1:57, function(i) FEP2(CESM1_future_list[[i]], 
                                                     threshold = CESM1_base$Qbl[i]))

# Create a temp data frame to save the result
CESM1_FRI_fp_df <- data.frame(subNo = 1:57, 
                              DFbl = DF_CESM1_fp_result, 
                              QFbl = QF_CESM1_fp_result, 
                              FEbl = FE_CESM1_fp_result, 
                              FEP = FEP_CESM1_fp_result, 
                              Qbl = CESM1_base$Qbl,
                              stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(CESM1_FRI_fp_df, "climate_re/update_ad_r/CESM1_FRI_fp_df.csv", row.names = FALSE)

## CRCM Future

CRCM_future_list <- future_list2[["CRCM_future"]]

# Use sapply to calculate the indices
DF_CRCM_fp_result <- sapply(1:57, function(i) DF2(CRCM_future_list[[i]], 
                                                  threshold = CRCM_base$Qbl[i]))
QF_CRCM_fp_result <- sapply(1:57, function(i) QF2(CRCM_future_list[[i]], 
                                                  threshold = CRCM_base$Qbl[i]))
FE_CRCM_fp_result <- sapply(1:57, function(i) FE(CRCM_future_list[[i]], 
                                                 threshold = CRCM_base$Qbl[i]))
FEP_CRCM_fp_result <- sapply(1:57, function(i) FEP2(CRCM_future_list[[i]], 
                                                    threshold = CRCM_base$Qbl[i]))

# Create a temp data frame to save the result
CRCM_FRI_fp_df <- data.frame(subNo = 1:57, 
                             DFbl = DF_CRCM_fp_result, 
                             QFbl = QF_CRCM_fp_result, 
                             FEbl = FE_CRCM_fp_result, 
                             FEP = FEP_CRCM_fp_result, 
                             Qbl = CRCM_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(CRCM_FRI_fp_df, "climate_re/update_ad_r/CRCM_FRI_fp_df.csv", row.names = FALSE)

## RCM3 Future

RCM3_future_list <- future_list2[["RCM3_future"]]

# Use sapply to calculate the indices
DF_RCM3_fp_result <- sapply(1:57, function(i) DF2(RCM3_future_list[[i]], 
                                                  threshold = RCM3_base$Qbl[i]))
QF_RCM3_fp_result <- sapply(1:57, function(i) QF2(RCM3_future_list[[i]], 
                                                  threshold = RCM3_base$Qbl[i]))
FE_RCM3_fp_result <- sapply(1:57, function(i) FE(RCM3_future_list[[i]], 
                                                 threshold = RCM3_base$Qbl[i]))
FEP_RCM3_fp_result <- sapply(1:57, function(i) FEP2(RCM3_future_list[[i]], 
                                                    threshold = RCM3_base$Qbl[i]))

# Create a temp data frame to save the result
RCM3_FRI_fp_df <- data.frame(subNo = 1:57, 
                             DFbl = DF_RCM3_fp_result, 
                             QFbl = QF_RCM3_fp_result, 
                             FEbl = FE_RCM3_fp_result, 
                             FEP = FEP_RCM3_fp_result, 
                             Qbl = RCM3_base$Qbl,
                             stringsAsFactors = FALSE)

# Save a csv file for each scenario
write.csv(RCM3_FRI_fp_df, "climate_re/update_ad_r/RCM3_FRI_fp_df.csv", row.names = FALSE)
