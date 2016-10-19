function FQbl(base,file)
% This function is designed to calculate the flood threshold from baseline scenario.
% 2-year flood was applied in our study, but this function can be easily modified to calculate other flood threshold.

% Parameters:
% base is the name of baseline scenario. Different baseline scenarios were used for different climate models.
% file is the user-defined file name of the output file with flood threshold for each sub-basin.

Qbl = zeros(57, 1);        % An array to store flood threshold of each subbasin, 57 is the number of subbasins in this study.

%% Baseline Q2
for i = 1:size(Qbl,1)      % size of Qbl should be the number of subbasins
    % Read SimDaily of baseline scenario
    data0 = importdata([base '\sim_daily' num2str(i) '.dat'],'\t',1);  % Make sure function is running under the right file directory.
    sim_data0 = data0.data(:, 3);
    
    % Find annual peak
    yrtot = floor(size(sim_data0, 1)/365) - 1;
    annualPeak = zeros(yrtot, 1);
    for yr = 1:yrtot
        % Start day of the water year, Oct. 1st
        % startDay = floor(274 + 365.25 * (yr - 1)); % Set as 274 if the start year is not a leap year
        startDay = floor(275 + 365.25 * (yr - 1)); % Set as 275 if the start year is a leap year
        
        if yr - 1 == 0 || mod((yr - 1), 4) ~= 0
            endDay = 364;
        else
            endDay = 365;
        end
        
        daily = sim_data0(startDay:(startDay + endDay), 1);
        annualPeak(yr) = max(daily);
    end
    
    % Determine flood recurrence
    Q = LP3(annualPeak);   % Q:[2,25,50,100yr flood], choose which one to use in the next line.
    Qbl(i) = Q(1);
end

% Write table with subNo, Qbl
fid = fopen(file,'w');
fprintf(fid, '%s\t%s\r\n', 'subNo', 'Qbl');


for i=1:57
    fprintf(fid,'%d\t%8.6f\r\n', i, Qbl(i, 1));
end

fclose(fid);

end
