function [ loc_max, loc_min ] = get_special_points( signal )
%Generates the vectors with the characteristic points.

dsignal = diff(signal);
[~, location] = findpeaks(dsignal, 'minpeakheight', 0.6*max(dsignal));
T = median(diff(location));
%% Se calculan los picos
% Conociendo el T (período), calculo los picos con findpeaks.

[~, loc_max] = findpeaks(signal, 'minpeakdistance', 0.9*T);
[~, loc_min] = findpeaks(-signal, 'minpeakdistance', 0.9*T);

end

