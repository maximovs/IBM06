function [ loc_zero ] = get_zero_points( signal )
%Generates the vectors with the characteristic points.

dsignal = diff(signal);
dsignal = avg_filter(5, 3, dsignal);
[~, loc_min] = get_special_points(dsignal);
loc_zero = loc_min(:);

for i = 1:length(loc_zero)
    pos = loc_zero(i);
    while pos<length(dsignal) && dsignal(pos) < dsignal(pos+1)
        pos = pos + 1;
    end
    loc_zero(i) = pos;
end
end

