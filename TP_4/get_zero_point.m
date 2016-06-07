function [ loc_zero ] = get_zero_point( signal )
%Generates the vectors with the characteristic points.

    dsignal = diff(signal);
    dsignal = avg_filter(5, 3, dsignal);
    [~, loc_min] = min(dsignal);
    loc_zero = loc_min;
    while loc_zero<length(dsignal) && dsignal(loc_zero) < dsignal(loc_zero+1)
        loc_zero = loc_zero + 1;
    end

end

