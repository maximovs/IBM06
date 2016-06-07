function [ ] = plot_fit( i, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat)
%PLOT_FIT Grafica un perfil de velocidad y una aproximación polinomial de grado 2.

[x,y] = get_perfil(i, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
p = polyfit(x, y, 2);
figure
plot(x, y); hold on;
d = x(1):0.01:x(end);
y1 = polyval(p, d);
plot(d, y1);

end

