function rsvproc(Par,pathOut,res_no,res_count,res_row,outlet_temp)

nsubs = res_count;
outlet = res_no;
start_year = year(Par.StartDate);
n_years = Par.nyrs;

iVars = [1 2 3 4 5 6 7 8 9 10]; % variables to include in sim file; 
% suggest you include them all.

%        RCH      GIS   MON     AREAkm2  FLOW_INcms FLOW_OUTcms     
% EVAPcms    TLOSScms  SED_INtons SED_OUTtonsSEDCONCmg/kg   ORGN_INkg  
% ORGN_OUTkg   ORGP_INkg  ORGP_OUTkg    NO3_INkg   NO3_OUTkg    NH4_INkg   
% NH4_OUTkg    NO2_INkg   NO2_OUTkg   MINP_INkg  MINP_OUTkg   CHLA_INkg  
% CHLA_OUTkg   CBOD_INkg  CBOD_OUTkg  DISOX_INkg DISOX_OUTkg 
% SOLPST_INmgSOLPST_OUTmg SORPST_INmgSORPST_OUTmg  REACTPSTmg    VOLPSTmg  
% SETTLPSTmgRESUSP_PSTmgDIFFUSEPSTmgREACBEDPSTmg   BURYPSTmg   BED_PSTmg 
% BACTP_OUTctBACTLP_OUTct  CMETAL#1kg  CMETAL#2kg  CMETAL#3kg     TOT Nkg  
% TOT Pkg NO3ConcMg/l    WTMPdegc

VarName = {'Flow(cms)';'Org N(kg)';'NO3N(kg)';'NH4N(kg)';'NO2N(kg)';...
    'TN(kg)';'Org P(kg)';'Min P(kg)';'TP(kg)';'Sediment(tons)'};

fid1=fopen([pathOut '/output.rsv'],'r');
fid2=fopen([pathOut '/sim_daily' num2str(outlet_temp) '.dat'],'w+');
fprintf(fid2,'Year\tDay');

for i=1:1:9
    temp=fgets(fid1);
end
ColNums = zeros(1,10);
for idx = 1:size(iVars,2)
    fprintf(fid2,'\t%s',VarName{iVars(idx)});
    if iVars(idx) == 1
        ColNums(1) = findstr(temp,'FLOW_OUTcms')+length('FLOW_OUTcms');
    elseif  min(((2:6) - iVars(idx)).^2) == 0 % 6. Total Nitrogen (Org N + NO3N + NH3N + NO2N)
        ColNums(2) = findstr(temp,'ORGN_OUTkg')+length('ORGN_OUTkg');
        ColNums(3) = findstr(temp,'NO3_OUTkg')+length('NO3_OUTkg');
        ColNums(4) = findstr(temp,'NH3_OUTkg')+length('NH3_OUTkg');
        ColNums(5) = findstr(temp,'NO2_OUTkg')+length('NO2_OUTkg');
    elseif min(((7:9) - iVars(idx)).^2) == 0 % 9. Total Phosphorus (Org P + Min P)
        ColNums(6) = findstr(temp,'ORGP_OUTkg')+length('ORGP_OUTkg');
        ColNums(7) = findstr(temp,'MINP_OUTkg')+length('MINP_OUTkg');
    elseif iVars(idx) == 10
        ColNums(8) = findstr(temp,'SED_OUTtons')+length('SED_OUTtons');
    end
end

fprintf(fid2,'\r\n');

for i=1:(res_row-1)
    temp=fgets(fid1);
end

k=1;
for Yidx=1:n_years
    
    tmp_yrPst = 0;
    yr_now = start_year + Yidx -1;
    if rem(yr_now,4)==0
        no_days = 366;
    else
        no_days = 365;
    end
    for day_n=1:no_days
        fprintf(fid2,'%d\t%d',yr_now,day_n);
        temp1=fgets(fid1);
        flag = zeros(1,5);
        for idx = 1:size(iVars,2)
            if iVars(idx) == 1 && flag(1) == 0
                try 
                Q(k,1) = str2num(temp1(ColNums(1)-10:ColNums(1)-1));
                catch 
                    k
                end
                OutVar(k,1) = Q(k,1);
                flag(1) = 1;
            elseif min(((2:6) - iVars(idx)).^2) == 0 && flag(2) == 0 % 6. Total Nitrogen (Org N + NO3N + NH3N + NO2N)
                OrgN(k,1) = str2num(temp1(ColNums(2)-10:ColNums(2)-1));
                NO3N(k,1) = str2num(temp1(ColNums(3)-10:ColNums(3)-1));
                NH4N(k,1) = str2num(temp1(ColNums(4)-10:ColNums(4)-1));
                NO2N(k,1) = str2num(temp1(ColNums(5)-10:ColNums(5)-1));
                TN(k,1) = OrgN(k,1) + NO3N(k,1) + NH4N(k,1) + NO2N(k,1);
                OutVar(k,2:6) = [OrgN(k,1) NO3N(k,1) NH4N(k,1) NO2N(k,1) TN(k,1)];
                flag(2) = 1;
            elseif min(((7:9) - iVars(idx)).^2) == 0 && flag(3) == 0 % 9. Total Phosphorus (Org P + Min P)
                OrgP(k,1) = str2num(temp1(ColNums(6)-10:ColNums(6)-1));
                MinP(k,1) = str2num(temp1(ColNums(7)-10:ColNums(7)-1));
                TP(k,1) = OrgP(k,1) + MinP(k,1);
                OutVar(k,7:9) = [OrgP(k,1) MinP(k,1) TP(k,1)];
                flag(3) = 1;
            elseif iVars(idx) == 10 && flag(4) == 0
                Sed(k,1) = str2num(temp1(ColNums(8)-10:ColNums(8)-1));
                OutVar(k,10) = Sed(k,1);
                flag(4) = 1;
            end
            fprintf(fid2,'\t%.4f',OutVar(k,iVars(idx)));
        end
        
        fprintf(fid2,'\r\n');
        for i=1:1:nsubs-1
            if feof(fid1)==0
                temp=fgets(fid1);
            end
        end
        
        k=k+1;
    end
    
end
fclose(fid1);
fclose(fid2);
fclose all;




