function [ last ] = last_min( vect )
%LAST_MIN Retorna el �ltimo m�nimo de la funci�n
%   Se comienza desde el final para detectar cu�l es el valor del �ltimo
%   m�nimo local de la funci�n.
    last = length(vect);
    while last > 1 && vect(last) > vect(last-1)
        last = last - 1;
    end
end

