function idx = find_index_of_SCE_drop(vec)
    % find the index in a vector where the difference of the value
    % at this index is greater than 10 percent of the value in the last index
    idx = 0; % initialize index to 0
    n = length(vec); % number of elements in vec
    full_drop_in_slope = vec(1)-min(vec);
    threshold = 0.1 * full_drop_in_slope; % threshold for difference
    for i = 1:n-1
        % fprintf("%d\n",vec(1)-vec(i));
        % check if the difference between vec(i) and vec(i+1) is greater than the threshold
        if vec(1)-vec(i) > threshold
            idx = i - 2; % update index
            break; % exit loop
        end
    end
    if idx == 0
        idx = 19;
    end
end