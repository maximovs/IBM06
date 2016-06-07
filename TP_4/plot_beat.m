function [  ] = plot_beat( vect, fs, x_label, y_label, vect_title )
%PLOT_BEAT Summary of this function goes here
%   Detailed explanation goes here

t = 0:1/fs:(length(vect)-1)/fs;
[~, location_max] = max(vect);
[~, location_min] = min(vect);
location_end = get_zero_point(vect);
figure
plot(t, vect,'r'); hold on;
xlabel(x_label)
ylabel(y_label)
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_end), vect(location_end), '*'); hold on;
plot(t(location_min), vect(location_min), '*');
title(vect_title)

end

