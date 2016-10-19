%%% This is a script demonstrates how to created sim_daily files
%%% using the functions "CreateSimDaily", "rchproc", and "rsvproc"
%%% After that, apply the function FQbl to calculate the flow rate
%%% of two-year flood.

% In this example, the script files (CreatSimDaily.m, rchproc.m, and rsvproc.m) 
% and the reservoir look-up table (res_lookup.txt)
% are stored in the folder "G:\ClimateJustice\YuChen\FloodIndex".

% The SWAT output files (output.rch and output.rsv) are stored in the
% folder "G:\ClimateJustice\YuChen\FloodIndex\GFDL_presentday_WLEB_leapyears"

%% Set the Par information

% Par is a structure containing the basic information of the watershed, including 
%    Par.climateFolders - path of the file folder with SWAT output
%    Par.StartDate - start date of the SWAT simulation excluding warm-up period
%    Par.EndDate - end date of the SWAT simulation
%    Par.nyrs - number of years simulated excluding warm-up period
%    Par.nsub - number of sub-basins
% scenario is the names of each folder with the SWAT output of corresponding climate scenario.

Par.climateFolders = 'G:\ClimateJustice\YuChen\FloodIndex';
Par.StartDate = datenum(1983,1,1);
Par.EndDate = datenum(1999,12,31);
Par.nyrs = 1 + year(Par.EndDate) - year(Par.StartDate);
Par.nsub = 57;
scenario = {'GFDL_presentday_WLEB_leapyears'};

%% Create sim_daily file for each subbasin using output.rch and output.rsv
CreateSimDaily(Par,scenario)

% After running the script, 57 sim_daily files, one for each sub-basin,
% are created in "G:\ClimateJustice\YuChen\FloodIndex\GFDL_presentday_WLEB_leapyears"

%% Calculate the two-year flood using the function FQbl

% base is the name of baseline scenario. Different baseline scenarios were used for different climate models.
% file is the user-defined file name of the output file with flood threshold for each sub-basin.
FQbl('GFDL_presentday_WLEB_leapyears', 'RCM4_GFDL__Qbl.txt')

% This creates a text file "RCM4_GFDL_Qbl.txt" in the folder "G:\ClimateJustice\YuChen\FloodIndex"
