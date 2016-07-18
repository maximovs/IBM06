function [ loc_10_pos, loc_10_neg ] = get_ios_and_eod( signal, percentage )
%GET_IOS_AND_EOD Summary of this function goes here
%   Detailed explanation goes here
d_signal = get_diff(signal);
[location_max, location_min] = get_special_points(d_signal);
[loc_10_pos] = get_percent_point(d_signal, location_max, percentage);
[loc_10_neg] = get_percent_point(-d_signal, location_min, percentage);

end

