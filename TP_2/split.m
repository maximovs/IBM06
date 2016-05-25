function [ vect1, vect2 ] = split( vect )
%SPLIT Summary of this function goes here
%   Detailed explanation goes here
    value = 1;
    for i = 1:length(vect)
        if vect(i,1) > vect(i+1,1) && vect(i+1,1) > vect(i+2,1)
            value = i;
            break;
        end
    end
    vect1 = vect(1:value, :);
    vect2 = fliplr(vect(value:length(vect), :)')';
end

