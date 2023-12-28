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
