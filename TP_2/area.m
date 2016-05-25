function [ result ] = area( vect )
%AREA Se obtiene la suma de las diferencias entre la zona superior del lazo
%y la zona inferior.
%   Se parte el vector en dos zonas de puntos, la superior y la inferior,
%   es decir, la comprendida entre el diámetro mínimo y el máximo y luego
%   la comprendida entre el diámetro máximo y el mínimo utilizando la
%   función split.
%   Se normaliza la zona superior de modo tal que en los mismos valores de
%   diámetro de la zona inferior exista un valor correspondiente a la zona
%   superior. Luego se calcula la sumatioria de las diferencias entre la
%   zona superior e inferior y en caso de que alguna diferencia resulta
%   menor que 0, se retorna -1, es decir, error.
    [upper, lower] = split(vect);
    upper = normalize(upper, lower(:,1));
    upper = upper(:,2);
    lower = lower(:,2);
    result = 0;
    for i = 1:length(upper)
        if upper(i) - lower(i) < 0
            result = -1;
            break;
        end
        result = result + upper(i) - lower(i);
    end
    
end

