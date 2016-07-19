function [ loc_10_pos, loc_10_neg ] = get_ios_and_eos( signal, percentage )
%GET_IOS_AND_EOD Se obtiene inicio y fin de sístole.
%   A partir de los máximos y mínimos se calcula los valores
%   correspondientes de inicio y fin de sístole a partir de los máximos y
%   mínimos de la derivada primera de la señal tal como fue visto en clase.
%   En el caso del inicio de sístole, se lo ubica cuando en el valor del
%   10% previo al pico positivo siguiente. En cambio, el fin de sístole, se ubica
%   en el valor del 10% previo al pico negativo siguiente.
d_signal = get_diff(signal);
[location_max, location_min] = get_special_points(d_signal);
[loc_10_pos] = get_percent_point(d_signal, location_max, percentage);
[loc_10_neg] = get_percent_point(-d_signal, location_min, percentage);

end

