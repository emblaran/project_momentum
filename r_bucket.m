
function r_port = r_bucket(varaible, edges)
    index = find(varaible>=edges, 1, 'last');
    if isempty(index)
        r_port = 1;
    else
        r_port = index + 1;
    end
end