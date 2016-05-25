function [ multiplier ] = get_multiplier( vect, dD_dt )
%GET_MULTIPLIER Se obtiene un multiplicador que minimice el área de vect.
%   Se incrementa el multiplicador de a delta iterando mientras que el
%   área se minimice y no se cambie el sentido del giro.
multiplier = 0.001;
delta = 0.001;

last_area = area(vect);
next_area = last_area;
next_multiplier = multiplier + delta;
while next_area > -1 && next_area <= last_area
    multiplier = next_multiplier;
    last_area = next_area;
    next_multiplier = multiplier + delta;
    next_vect = vect - [zeros(length(dD_dt),1) next_multiplier*dD_dt];
    next_area = area(next_vect);
end


end

