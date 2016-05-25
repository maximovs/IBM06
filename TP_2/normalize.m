function [ out ] = normalize( vect, other_x )
%NORMALIZE Se normaliza el vector en función de otro conjunto x
%   Se normaliza el vector vect de modo tal que exista un valor y para cada
%   punto del nuevo conjunto de x other_x.
%   Estos valores de y se obtienen interpolando los valores de y reales del 
%   vector vect cercanos al valor de x deseado.
    out = zeros(length(other_x), 2);
    out(:,1) = other_x;
    for i = 1:length(other_x)
        value = vect(length(vect),2);
        for j = 1:length(vect)
            if other_x(i) >= vect(j) && j<length(vect) && other_x(i) < vect(j+1)
                delta_x = (other_x(i)-vect(j,1)) / (vect(j+1,1) - vect(j,1));
                value = vect(j,2) + (vect(j+1,2) - vect(j,2))*delta_x;
            end
        end
        out(i,2) = value; 
    end
end

