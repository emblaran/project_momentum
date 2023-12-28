% Number of portfolios
N = 10;

% Sorting stocks into N portfolios based on lagged idiosyncratic volatility
[~, edges, bin] = histcounts(mergedData.lagged_ivol, N);

% Computing value-weighted returns for each portfolio
for i = 1:N
    portfolioIdx = (bin == i);
    mergedData.portfolio_returns(portfolioIdx) = mergedData.retadj(portfolioIdx) .* mergedData.me(portfolioIdx);
end

% Calculating average value-weighted returns for each portfolio
average_returns = zeros(N, 1);
for i = 1:N
    portfolioIdx = (bin == i);
    average_returns(i) = nanmean(mergedData.portfolio_returns(portfolioIdx));
end

% Displaying average returns for value-weighted portfolios
disp('Average Value-Weighted Returns for Each Portfolio:');
disp(average_returns);

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
