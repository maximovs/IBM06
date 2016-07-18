function [ points ] = get_percent_point( signal, points, percentage )
%GET_10_PERCENT_POINT Devuelve los puntos en la señal de modo que
%representen un 10% del valor del punto recibido "retrocediendo" en el
%tiempo
for i=1:length(points)
    point = points(i);
    value = signal(point);
    while point > 1 && signal(point) > value*percentage
        point = point-1;
    end
    points(i) = point;
end
end

