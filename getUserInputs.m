function [ Par ] = getUserInputs( )

fidin = fopen('USER_INPUTS.txt','r');

if fidin > 0
    
    % Get watershed-specific inputs
    titleString = ('User inputs specific to watershed');
    tempin = fgets(fidin);
    while size(strfind(strtrim(tempin),strtrim(titleString)),1) <= 0
        tempin = fgets(fidin);
    end
    tempin = fgets(fidin);
    Par.outlet = str2num(tempin(1:20));    tempin = fgets(fidin);
    Par.nhrus = str2num(tempin(1:20));     tempin = fgets(fidin);
    Par.n = str2num(tempin(1:20));         tempin = fgets(fidin);
    Par.nsub = str2num(tempin(1:20));      tempin = fgets(fidin);
    Par.watm2 = str2num(tempin(1:20));     tempin = fgets(fidin);
    
    % get SWAT-setup-specific inputs
    titleString = ('User inputs specific to SWAT setup');
    while size(strfind(strtrim(tempin),strtrim(titleString)),1) <= 0
        tempin = fgets(fidin);
    end
    tempin = fgets(fidin);
    Par.warmup = str2num(tempin(1:20));    tempin = fgets(fidin);    
    Par.StartDate = datenum(str2num(tempin(14:17)),...
        str2num(tempin(8:9)),...
        str2num(tempin(11:12)));            tempin = fgets(fidin);   
    Par.EndDate = datenum(str2num(tempin(14:17)),...
        str2num(tempin(8:9)),...
        str2num(tempin(11:12)));            tempin = fgets(fidin);       

else
    
    disp('ERROR: USER_INPUT.txt does not exist')

end

Par.nyrs = 1 + year(Par.EndDate) - year(Par.StartDate); 