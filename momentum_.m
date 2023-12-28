clear
close all


return_m_hor=readtable('return_monthly.xlsx','ReadVariableNames',true,'PreserveVariableNames',true,'Format','auto');


return_m=stack(return_m_hor,3:width(return_m_hor),'NewDataVariableName','return_m',...
'IndexVariableName','date');
writetable(return_m,'myPatientData.xlsx','WriteRowNames',true) 
return_m.date=char(return_m.date);
return_m.datestr=datestr(return_m.date);
return_m.date=datetime(return_m.datestr,'InputFormat','dd-MMM-yyyy','Locale','en_US');
return_m.return_m=return_m.return_m/100;


% Read the file with previous month market capitalizaiton 


market_cap_lm_hor=readtable('me_lag.xlsx','ReadVariableNames',true,'PreserveVariableNames',true,'Format','auto');
market_cap_lm=stack(market_cap_lm_hor,3:width(market_cap_lm_hor),'NewDataVariableName','lme',...
'IndexVariableName','date');
market_cap_lm.date=char(market_cap_lm.date);
market_cap_lm.datestr=datestr(market_cap_lm.date);
market_cap_lm.date=datetime(market_cap_lm.datestr,'InputFormat','dd-MMM-yyyy','Locale','en_US');

% merge two files 
return_monthly=outerjoin(return_m,market_cap_lm,'Keys',{'date','code','name','datestr'},'MergeKeys',true,'Type','left');
return_monthly=sortrows(return_monthly,{'code','date'},{'ascend','ascend'});

index=~isnan(return_monthly.lme);
return_monthly=return_monthly(index,1:end);

save return_m.mat return_monthly;

%%

% (b) Every K months, sort stocks into five groups based on previous K months' return and hold this position for K months. 
% What is the average equal-weighted return spread between high and low previous stock returns portfolios 
% for K = 1; 3; 6; 12; 24. Do you find that momentum exists in Chinese stock markets?

% First we create a new dataset with K = 1; 3; 6; 12; 24;, which denotes
% the frequency month returns.

% Define the values of K
K_values = [1, 3, 6, 12, 24];

% Loop over each value of K
for i = 1:length(K_values)
    K = K_values(i);

    % Create a new dataset with previous K months return
    return_m_k = return_m;
    return_m_k.return_m_lagged = lagmatrix(return_m.return_m, K);

    % Sort stocks into five groups based on previous K months' return
    return_m_k = sort_stocks(return_m_k, K);

    % Displaying the results
    %disp(['Dataset with previous ', num2str(K), ' months return and sorted stocks:']);
    %disp(return_m_k);

    
    % We want to save the new dataset for each value of K
    save(['return_m_k_', num2str(K), '.mat'], 'return_m_k');
end

% So return_m_k is now our new dataset, based on the task in b).

%% Portfolio Analysis 

% We can split portfolio analysis into the follwing steps:
% Calculate the breakpoints that will be used to divide the sample into portfolios
% Use these breakpoints to form the portfolios
% Calculate the average value of the outcome variable Y with each portfolio for each period t
% Examine variation in these average values of Y across the different portfolios

% We have already formed the portfolios so we only have to do the last two
% steps.

% Number of portfolios
N = 5; %for different values of K

% Sorting stocks into N portfolios based on lagged idiosyncratic volatility
[~, edges, bin] = histcounts(return_m_k.return_m_lagged, N);
% We have already sorted stocks by return_m_k - must be specify to
% return_m_k.lagged


% Computing value-weighted returns for each portfolio
for i = 1:N
    portfolioIdx = (bin == i);
    return_m_k.portfolio_returns(portfolioIdx) = return_m_k.return_m(portfolioIdx) .* return_m_k.return_m_lagged(portfolioIdx); %.*return_m_k.me(portfolioIdx)
end

% Calculating average value-weighted returns for each portfolio
average_returns = zeros(N, 1);
for i = 1:N
    portfolioIdx = (bin == i);
    average_returns(i) = nanmean(return_m_k.portfolio_returns(portfolioIdx));
end

% Displaying average returns for value-weighted portfolios
disp('Average Value-Weighted Returns for Each Portfolio:');
disp(average_returns);

%%

% Function to sort stocks into five groups based on previous K months' return
function data_sorted = sort_stocks(data, K)
    % Add code here to sort stocks into five groups based on previous K months' return
    % For example, you can use quantiles or other criteria
    % Store the group information in a new variable, e.g., 'group'
    data.group = discretize(data.return_m_lagged, linspace(min(data.return_m_lagged), max(data.return_m_lagged), 6), 'IncludedEdge', 'right');
    data.group = categorical(data.group);
    data.Properties.VariableNames{end} = 'group';
    
    data_sorted = data;
end


