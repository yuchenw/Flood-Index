function FQbl(base,file)

%% 0T0P as baseline
Qbl = zeros(57, 1);        % Baseline flood extent(5yr flood) each sub

%% Baseline Q2
for i = 1:57
    %read simdaily of baseline
    data0 = importdata([base '\sim_daily' num2str(i) '.dat'],'\t',1);
    sim_data0 = data0.data(:, 3);
    %find annual peak
    yrtot = floor(size(sim_data0, 1)/365) - 1;
    annualPeak = zeros(yrtot, 1);
    for yr = 1:yrtot
        % startDay = floor(274 + 365.25 * (yr - 1)); % Set as 274 if the start year is not a leap year
        startDay = floor(275 + 365.25 * (yr - 1)); % Set as 275 if the start year is not a leap year
        
        if yr - 1 == 0 || mod((yr - 1), 4) ~= 0
            endDay = 364;
        else
            endDay = 365;
        end
        
        daily = sim_data0(startDay:(startDay + endDay), 1);
        annualPeak(yr) = max(daily);
    end
    
    % 2-yr flood
    Q = LP3(annualPeak);   %Q: 2,5,10,25,50,100yr flood
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