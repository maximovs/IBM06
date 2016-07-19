function [ loc_10_pos, loc_10_neg ] = get_ios_and_eos( signal, percentage )
%GET_IOS_AND_EOD Se obtiene inicio y fin de s�stole.
%   A partir de los m�ximos y m�nimos se calcula los valores
%   correspondientes de inicio y fin de s�stole a partir de los m�ximos y
%   m�nimos de la derivada primera de la se�al tal como fue visto en clase.
%   En el caso del inicio de s�stole, se lo ubica cuando en el valor del
%   10% previo al pico positivo siguiente. En cambio, el fin de s�stole, se ubica
%   en el valor del 10% previo al pico negativo siguiente.
d_signal = get_diff(signal);
[location_max, location_min] = get_special_points(d_signal);
[loc_10_pos] = get_percent_point(d_signal, location_max, percentage);
[loc_10_neg] = get_percent_point(-d_signal, location_min, percentage);

end

