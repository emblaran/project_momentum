function result = k_month_return(returns, k)
    result = zeros(length(returns), 1);
    len = length(returns);

    result_tmp = cumprod(1 + returns);   
    result_tmp_2 = result_tmp(k:k:len-1);

    result(k+1:k:len) = ...
        (result_tmp_2 ./ [1; result_tmp_2(1:end-1)]) - 1;
    if k > 1
        indices = mod(1:len, k) ~= 1;
        result(indices) = nan;
    end
    result(1) = nan;
    result = mat2cell(result, len, 1);
end