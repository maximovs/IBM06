function [ avg_beat ] = get_avg_beat( signal )
%GET_AVG_BEAT Obtiene el comportamiento de la señal en promedio en cada
%ciclo
%   Se calcula la cantidad de ciclos a partir de los mínimos de la
%   señal. Se calcula T, la duración de un ciclo, como el máximo de todos
%   los ciclos. Se calcula el valor medio de todos los ciclos para cada
%   instante de T. De esta forma, se obtiene un ciclo de valor medio.
    [~, loc_min] = get_special_points(signal);
    T = max(diff(loc_min));
    beats = zeros(length(loc_min), T);
    for i= 1:length(loc_min)
        start = loc_min(i);
        for j=1:T
           if length(signal) > start+j
                beats(i,j) = signal(start+j); 
           end
        end
    end
    avg_beat = zeros(T,1);
    for i = 1:T
        avg_beat(i) = median(beats(:,i));
    end
end

