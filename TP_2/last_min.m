function [ last ] = last_min( vect )
%LAST_MIN Retorna el último mínimo de la función
%   Se comienza desde el final para detectar cuál es el valor del último
%   mínimo local de la función.
    last = length(vect);
    while last > 1 && vect(last) > vect(last-1)
        last = last - 1;
    end
end

