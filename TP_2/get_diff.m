function [ dif ] = get_diff( value )
%GET_DIFF Summary of this function goes here
%   Detailed explanation goes here
    dif = diff(value);
    dif = [dif' dif(end)]';

end

