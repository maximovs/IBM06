function [ diametro, perfil ] = get_perfil( t, v1, v2, v3, dao )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
d = dao(t);
perfil = [v1(t) v2(t) v3(t) v2(t) v1(t)];
diametro = [-d/2, -d/4, 0 , d/4, d/2 ];
end

