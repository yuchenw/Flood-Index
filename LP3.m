function Xret = LP3(annualpeak)
%%% LOG PEARSON TYPE III DISTRIBUTION %%%

% Load data and check record length
X = annualpeak(:,1);
Y = log10(X); % use log 10 transformed data
N = length(Y);

% Rank data from lowest to highest
RankedY = sortrows(Y);

% Plotting positions: Calculate exceedance (q) and nonexceedance (p) probabilities
rank = N:-1:1;
a = 0.4; % Cunnane
q = (rank - a)/(N + 1 - 2*a);
p = 1-q;
T = 1./q;

% Sample statistics
sy = std(Y); % sample standard deviation
my = mean(Y);  % sample mean
gy = skewness(Y);
sx = std(X);
mx = mean(X);
gx = skewness(X);

% Calculate the reduced variate, yp, for each p
z = norminv(p,0,1);

%%% Parameter estimates %%%
 
% Method of Moments
k1 = gy/6;
Kt = z+(z.^2-1)*k1+(1/3)*(z.^3-6*z)*(k1^2)-(z.^2-1)*(k1^3)+ z.*(k1^4)+(1/3)*(k1^5);
yt = my + Kt*sy;
% 
%%% Plotting flood frequency diagrams %%%

% Create return period labels
Tlabel = [1.5,2,5,10,50,100];

% Find exceedance probability and non-exceedance probability
qlabel = 1./Tlabel;
plabel = 1.-qlabel;
zlab = norminv(plabel,0,1);

% Create labels
xlab = 'Return Period (years)';
ylab = 'Log10( Flow Rate (cfs) )';

% % Plotting with createfigure function
% createfigure(Kt,RankedY,30,'k',zlab, xlab, ylab);
% hold on
% %plot(zp,xp,'-k','LineWidth',2);
% plot(Kt,yt,'-k','LineWidth',2);
% hold off


%%% Chi Square test %%%

% Calculting Chi Square
k = 20;
bins = [0];
n = [];
np = [];
sqdiff = [];
sumsqdiff = 0;
bounds = [0];
K = [];

for i=1:k
    bins = [bins i/k]; % number of bins

    z = norminv(bins(i+1),0,1);
    K = [K (z+(z.^2-1)*k1+(1/3)*(z.^3-6*z)*(k1^2)-(z.^2-1)*(k1^3)+ z.*(k1^4)+(1/3)*(k1^5))];
    Pbound = bins(i+1);
    Xbound = 10^(my+(K(i))*sy); % upper bound on X for bin i
    bounds = [bounds Xbound];
    
    count = 0; % counts the number of elements in bin i
    for j=1:N
        if X(j) <= bounds(i+1)
            if X(j) > bounds(i)
                count = count + 1;
            end
        end
    end
    
    n = [n count]; % add to matrix ni
    np = [np 101/k]; % add to matrix npi
    sqdiff = [sqdiff ((n(i)-np(i))^2)]; % calculate numerator of d1
    sumsqdiff = sumsqdiff + ((n(i)-np(i))^2); % sum numerator of d1
end
d1 = sumsqdiff/np(1); % calculate test statistic
   
%%% Kolmogorov-Smirnov %%%
d2 = 0;
F = normcdf(RankedY,my,sy);

for i=1:N
    Fstar = p(i);
%    F = normcdf(log(X(i)),my,sy)
%    F = normcdf(X(i),mx,sx)
    if abs(Fstar-F(i)) > d2
        d2 = abs(Fstar-F(i));
    end
end
% d2


%%% Predicting flows for return periods %%%

returnperiods = [2,25,50,100]
Tret = [];
Pret = [];
Xret = [];
Kret = [];

for i=1:4
    Tret = [Tret returnperiods(i)];
    Pret = [Pret 1-1/Tret(i)];
    z = norminv(Pret(i),0,1);
    Kret = [Kret (z+(z.^2-1)*k1+(1/3)*(z.^3-6*z)*(k1^2)-(z.^2-1)*(k1^3)+ z.*(k1^4)+(1/3)*(k1^5))];
    Xret = [Xret 10^(my+sy*Kret(i))];
end

Xret

% [H,P,KSSTAT] = kstest2(RankedY,yt)
end