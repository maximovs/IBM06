function [ next_min ] = get_next_min( signal, start )
%GET_NEXT_MIN Summary of this function goes here
%   Detailed explanation goes here
next_min = start;
   while (signal(next_min)> signal(next_min+1))
       next_min = next_min + 1;
   end

end

