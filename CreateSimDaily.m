function CreateSimDaily(Par,scenario)

for s = 1:numel(scenario)
    foldername = char(scenario{s});
    pathOut=[Par.climateFolders '\' foldername];
    
    % CREATE SIMULATION FILES AND CALCULATE STATISTICS
    % For each watershed outlet
    disp(['Creating sim files...' num2str(s) '/' num2str(numel(scenario))])
    
    for outlet_temp = 1:Par.nsub;
        disp(['Writing sim_daily ' num2str(outlet_temp)])
        % Creating simdaily files
        fid_res = fopen('res_lookup.txt','r');
        res_data = textscan(fid_res,'%d%d','HeaderLines',1,'delimiter','\t');
        res_lookup = [double(res_data{1}) double(res_data{2})];
        if ismember(outlet_temp,res_lookup(:,2))
            [~, res_row]= ismember(outlet_temp,res_lookup(:,2));
            res_no = res_lookup(res_row,1); % reservoir number corresponding to reach
            res_count = length(res_lookup(:,1)); % total number of reservoirs
            rsvproc(Par,pathOut,res_no,res_count,res_row,outlet_temp) % outlet is in subbasin with a reservoir; use output.rsv
        else
            rchproc(Par,pathOut,outlet_temp) % outlet subbasin has no reservoir; use output.rch
        end
    end
    
end
end
