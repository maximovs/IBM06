function [ f ] = to_time( mod_f, pha_f, t )
%A partir del módulo y fase de las armónicas, se calcula la función
%original en el espacio temporal.
f_i = zeros(length(mod_f),length(t));
f_i(1,:) = mod_f(1);
for i=2:length(mod_f)
    f_i(i,:) = mod_f(i)*cos(2*pi*(i-1)*t + pha_f(i));
end
f = sum(f_i);

end

