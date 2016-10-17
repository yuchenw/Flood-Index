# Flood Index Calculation

This document describes how to calculate the flood index based on the Soil and Water Assessment Tool (SWAT, http://swat.tamu.edu/) simulated flow data.

## Software and Dataset Requirement:
1.	SWAT output files (output.rch and output.rsv).
2.	Matlab program (version R2015b or later, https://www.mathworks.com/products/new_products/release2015b.html). 
3.	R program (version 3.3.1 or later, https://cran.r-project.org/).
4.	R package dplyr (version 0.5.0 or later, https://cran.r-project.org/web/packages/dplyr/index.html) 
5.	R package lubridate (version 1.6.0 or later, https://cran.r-project.org/web/packages/lubridate/index.html) 

## Steps:

#### Create a file to show simulated flow of each sub-basin based on output.rch and output.rsv.

A file to show simulated flow of each sub-basin is necessary to determine the level of two-year flood. We used several Matlab scripts (`CreateSimDaily.m`, `rchproc.m`, `rsvproc.m`) to achieve this task.

It is necessary to create a look-up table showing if a sub-basin contains a reservoir (see https://drive.google.com/a/umich.edu/file/d/0Bz2-pWCMig8fcERaY05VQnF4ZmM/view?usp=sharing as an example). After that, use `CreateSimDaily.m` to get the simulated flow and nutrient values out of each sub-basin. If there are no reservoirs in a sub-basin, the `CreateSimDaily` function uses `rchproc` function to extract values out of each sub-basin; instead, if there are reservoirs in a sub-basin, `CreateSimDaily` uses `rsvproc` function to extract values.

The outputs, named as `SimDaily data`, are files with `dat` extension showing simulated daily flow and nutrient loads of each sub-basin. We provided outputs from our study as examples on the Google Drive folder `SimDaily` (https://drive.google.com/open?id=0Bz2-pWCMig8fTEJtSlNIZG44M3M). Under this folder, the folder `Sensitivity_Test` contains 30 `zip` files, while the folder `Climate_Model` contains 10 `zip` files. Each zip file represents one scenario, containing 57 `dat` files for each sub-baisn. For example, `sim_daily1` means the simulated values of sub-basin 1.

#### Calculate the level of two-year flood of each sub-baisn.

We used two Matlab scripts (`FQbl.m` and `LP3.m`) to calculate the two-year flood of the baseline scenarios. The level of two-year flood will be the threshold to determine if a flood event happens when calculate flood indices in the next step. For climate sensitivity test, the baseline scenario is the condition when no temperature or precipitation change (T+0°C P+0%). For climate model test, the baseline scenario is the historical condition of each climate model. 

The function `FQbl` first finds the annual peak flow of each sub-basin, then applies `LP3` function to calculates the two-year flood based on the recurrence interval. 

The outputs are text files showing the level of two-year flood. We provided outputs from our study as examples on the Google Drive folder `Qbl` (https://drive.google.com/drive/folders/0Bz2-pWCMig8fdkVUQlk4N1VoazQ?usp=sharing). `0T0P_Qbl.txt` contains threshold for the climate sensitivity test. Other text files contain threshold for climate model test.

#### Calculate flood indices

We used R scripts to calculate flood indices of each sub-basin and each scenario. First, `Function_readSimDaily.R` contains functions to pre-process the `SimDaily data` to add water year information and only keep flow data. After that, `Function_Flood_Index.R` contains several functions to calculate flood exceedance probability, flood duration, flood magnitude, and flood frequency index. The outputs are `csv` files. Each files contain six columns, showing sub-basin number, **flood duration** (**FD**), **flood magnitude** (**FM**), **flood frequency** (**FF**), **flood exceedance probability** (**FEP**), and the level of two-year flood (**Qbl**). We provide the outputs in the Google Drive folder `Flood_Index` (https://drive.google.com/open?id=0Bz2-pWCMig8fUUJIZHVuQmUxRk0). The results of the climate sensitivity test and climate model test in the folder `Sensitivity_Test` and `Climate_Model`, respectively. We also provide our R scripts (`FI_sensitivity.R` and `FI_climate.R`) to demonstrate the use of these functions to calculate flood indices.

