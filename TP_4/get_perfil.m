function [ diametro, perfil ] = get_perfil( t, v1, v2, v3, dao )
%GET_PERFIL Retorna un vector con las velocidades en cada parte de la
%arteria y los puntos donde se miden dichas velocidades. Se estima que los
%valores son espejados y equidistantes.
d = dao(t);
perfil = [v1(t) v2(t) v3(t) v2(t) v1(t)];
diametro = [-d/2, -d/4, 0 , d/4, d/2 ];
end

