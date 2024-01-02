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