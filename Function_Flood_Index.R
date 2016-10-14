### Functions to calculate the flood index

# Load packages
library(dplyr)
library(lubridate)

### Helper functions:

# A function to calculate the run length of each flood
runlen_helper <- function(input, threshold){
  
  input1 <- input %>% mutate(Flood = ifelse(Flow >= threshold, 1, 0))
  len <- rle(input1$Flood)
  len_vec <- len$lengths[len$values == 1]
  return(len_vec)
}

# A helper function to calculate flood duration
FD_helper <- function(input, threshold){
  
  len_vec <- runlen_helper(input, threshold)
  return(mean(len_vec))
}


# A helper function to calculate flood magnitude
FM_helper <- function(input, threshold){
  
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


### The main functions for flood index

# Flood Exceedance Probability
FEP_Index <- function(input, threshold){
  input1 <- input %>%
    mutate(Flood= ifelse(Flow >= threshold, 1, 0))%>%
    group_by(Wateryear) %>%
    summarise(Totalday = sum(Flood)) %>%
    ungroup() %>%
    mutate(Prob = ifelse(leap_year(Wateryear), Totalday/366 * 100, Totalday/365 * 100))
  return(mean(input1$Prob))
}

# Flood Duration 
FD_Index <- function(input, threshold){
  DFnum <- sapply(unique(input$Wateryear), 
                  function(i) FD_helper(input[input$Wateryear == i, ], threshold = threshold))
  DFnum[is.nan(DFnum)] <- 0
  return(mean(DFnum))
}

# Flood Magnitude
FM_Index <- function(input, threshold){
  FMnum <- sapply(unique(input$Wateryear), 
                  function(i) FM_helper(input[input$Wateryear == i, ], threshold = threshold))
  FMnum[is.nan(FMnum)] <- 0
  return(mean(FMnum))
}

# Flood Frequency
FF_Index <- function(input, threshold){
  len_vec <- runlen_helper(input, threshold)
  
  Yearnum <- length(unique(input$Wateryear))
  
  return(length(len_vec)/Yearnum)
}