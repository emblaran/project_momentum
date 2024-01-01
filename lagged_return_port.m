% Function to sort stocks into N groups based on previous K months' return
function data_sorted = lagged_return_port(data, N, breakpoint, variable)
    % Add code here to sort stocks into five groups based on previous K months' return
    % For example, you can use quantiles or other criteria
    % Store the group information in a new variable, e.g., 'lr_port'
    
    %breakpoint
    [G, yymm] = findgroups(data.(breakpoint));

    %prctile edges
    edges = zeros(length(yymm), N-1); %N-1 edges for N portfolios, N=5

    for i=1:N-1
        %function handle
        prct = @(input) prctile(input, 100/N * i);
        %calculate edges
        edges(:, i) = splitapply(prct, data.(variable), G);
    end
    %breakpoints
    break_point = table(yymm, edges);
    data_bp = outerjoin(data, break_point, "Keys", "yymm", "MergeKeys",true,"Type","left");
    lr_port = rowfun(@r_bucket, data_bp(:, [variable, 'edges']), "Outputformat", "cell");
    data.lr_port = cell2mat(lr_port);

    %output
    data_sorted = data;
end