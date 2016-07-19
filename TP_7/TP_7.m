%% Importo los datos
% Se utiliza la función autogenerada por Matlab
[PVI, PVD, VVIendo, VVDendo] = read_data();

%% Filtrado de datos
% Es necesario aplicar un filtrado importante ya que los datos tienen mucho
% ruido y afectan las funciones para calcular los puntos característicos.

PVI = avg_filter(8, 5, PVI);
PVD = avg_filter(8, 5, PVD);
VVI = avg_filter(5, 3, VVIendo);
VVD = avg_filter(5, 3, VVDendo);
PVI = PVI - min(min(PVI, 0));
PVD = PVD - min(min(PVD, 0));
VVI = VVI - min(min(VVI, 0));
VVD = VVD - min(min(VVD, 0));
fs = 250;
t = 0:1/fs:(length(PVI)-1)/fs;

%% Se calcula inicio y fin de sístole
% Con el método visto en clase se calcula los puntos de inicio y fin de
% sístole en cada ventrículo.
figure
subplot(3,1,1)
vect = PVI;
[location_max, location_min] = get_special_points(vect);
[loc_10_p, loc_10_n] = get_ios_and_eos(vect, 0.11);
pfs_i = PVI(loc_10_n);
vfs_i = VVI(loc_10_n);
pfd_i = PVI(loc_10_p);
vfd_i = VVI(loc_10_p);
plot(t, vect,'r'); hold on;
plot(t, get_diff(vect),'b'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min), vect(location_min), '*');
plot(t(loc_10_p), vect(loc_10_p), 'x'); hold on;
plot(t(loc_10_n), vect(loc_10_n), 'o'); hold on;
xlabel('t (s)')
ylabel('p (mmHg)')
title('Presión del ventrículo izquierdo.')
subplot(3,1,2)
vect = PVI(1:500);
[location_max, location_min] = get_special_points(vect);
[loc_10_p, loc_10_n] = get_ios_and_eos(vect, 0.11);
plot(t(1:500), vect,'r'); hold on;
plot(t(1:500), get_diff(vect),'b'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min), vect(location_min), '*'); hold on;
plot(t(loc_10_p), vect(loc_10_p), 'x'); hold on;
text(t(loc_10_p), vect(loc_10_p),'\leftarrow Inicio de sístole')
plot(t(loc_10_n), vect(loc_10_n), 'o'); hold on;
text(t(loc_10_n), vect(loc_10_n),'\leftarrow Fin de sístole')
xlabel('t (s)')
ylabel('p (mmHg)')
title('Presión del ventrículo izquierdo.')
subplot(3,1,3)
vect = VVI;
plot(t, vect,'r');
xlabel('t (s)')
ylabel('v (ml)')
title('Volumen del ventrículo izquierdo.')
figure
subplot(3,1,1)
vect = PVD;
[location_max, location_min] = get_special_points(vect);
[loc_10_p, loc_10_n] = get_ios_and_eos(vect, 0.11);
pfs_d = PVD(loc_10_n);
vfs_d = VVD(loc_10_n);
plot(t, vect,'r'); hold on;
plot(t(loc_10_p), vect(loc_10_p), '+'); hold on;
plot(t(loc_10_n), vect(loc_10_n), 'o'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min), vect(location_min), '*');
xlabel('t (s)')
ylabel('p (mmHg)')
title('Presión del ventrículo derecho.')
subplot(3,1,2)
vect = PVD(1:500);
[location_max, location_min] = get_special_points(vect);
[loc_10_p, loc_10_n] = get_ios_and_eos(vect, 0.11);
plot(t(1:500), vect,'r'); hold on;
plot(t(1:500), get_diff(vect),'b'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min), vect(location_min), '*'); hold on;
plot(t(loc_10_p), vect(loc_10_p), 'x'); hold on;
text(t(loc_10_p), vect(loc_10_p),'\leftarrow Inicio de sístole')
plot(t(loc_10_n), vect(loc_10_n), 'o'); hold on;
text(t(loc_10_n), vect(loc_10_n),'\leftarrow Fin de sístole')
xlabel('t (s)')
ylabel('p (mmHg)')
title('Presión del ventrículo derecho.')
subplot(3,1,3)
vect = VVD;
plot(t, vect,'r');
xlabel('t (s)')
ylabel('v (ml)')
title('Volumen del ventrículo derecho.')


%% Lazo PV - VV de ambos ventrículos
% Se grafica el lazo PV - VV de ambos ventrículos para todos los puntos de
% presión y volumen a lo largo del tiempo. Con los puntos calculados, se
% estima la función de la recta Emax que minimice la distancia a los puntos
% de fin de sístole. A partir de ella, se calcula V0 para cada ventrículo.
figure
p = polyfit(vfs_d, pfs_d, 1);
e_max_d = p(1);
d = 35:0.01:max(VVD);
y1 = polyval(p, d);
v0_d = -p(2)/p(1);
plot(d, y1); hold on;
plot(vfs_d, pfs_d, '*'); hold on;
plot(v0_d, 0, 'x'); hold on;
text(v0_d, 0,['\leftarrow V0:' num2str(v0_d)])
plot(VVD, PVD, 'g');
title('Bucle del ventrículo derecho.')

figure
p = polyfit(vfs_i, pfs_i, 1);
e_max_i = p(1);
d = 40:0.01:max(VVI);
y1 = polyval(p, d);
v0_i = -p(2)/p(1);
plot(d, y1); hold on;
plot(vfs_i, pfs_i, '*'); hold on;
plot(v0_i, 0, 'x'); hold on;
plot(VVI, PVI, 'g');
text(v0_i, 0,['\leftarrow V0:' num2str(v0_i)])
title('Bucle del ventrículo izquierdo.')

%% Cálculo de elastancia y compliance
% Se calcula la elastancia en función del tiempo utilizando V0 calculado
% anteriormente. Luego se invierte la elastancia para calcular la
% compliance y, en los casos que la elastancia se acerca a 0, se limita el
% valor máximo de la compliance. Esto se realiza, una vez calculada la
% compliance, cortando todos los valores que superan en 10 veces el valor
% de la mediana.
figure
e_d = PVD./(VVD-v0_d);
E_max = ones(length(t),1) .* e_max_d;
E_min = ones(length(t),1) .* min(e_d);
plot(t, E_min); hold on;
text(t(1), e_max_d,['Emax:' num2str(e_max_d)])
plot(t, E_max); hold on;
c_d = 1./e_d;
median_c = median(c_d);
for i=1:length(c_d)
    if c_d(i) > 10* median_c
        c_d(i) = c_d(i-1);
    end
end
h = plotyy(t, e_d, t, c_d);
xlabel('t (s)')
ylabel(h(1),'e (mmHg/ml)')
ylabel(h(2),'c (ml/mmHg)')
title('Elastancia del ventrículo derecho.')

figure
e_i = PVI./(VVI-v0_i);
E_min = ones(length(t),1) .* e_max_i;
E_max = ones(length(t),1) .* min(e_i);
plot(t, E_min); hold on;
text(t(1), e_max_i,['Emax:' num2str(e_max_i)])
plot(t, E_max); hold on;
c_i = 1./e_i;
median_c = median(c_i);
for i=1:length(c_i)
    if c_i(i) > 10* median_c
        c_i(i) = c_i(i-1);
    end
end
h = plotyy(t, e_i, t, c_i);
xlabel('t (s)')
ylabel(h(1),'e (mmHg/ml)')
ylabel(h(2),'c (ml/mmHg)')
title('Elastancia del ventrículo izquierdo.')

%% Cálculo del acoplamiento ventrículo-arterial.
% Se calcula Emax para el ventrículo izquierdo y luego Ea. Se grafica ambos
% y se observa que a lo largo de los latidos los valores se acercan
% bastante. Si llegaran a ser iguales, se produciría un acoplamiento
% óptimo.

figure
e_max = pfs_i./(vfs_i - v0_i);
e_a = pfs_i./(vfd_i-vfs_i);
plot(e_max); hold on;
text(1, e_max(1), 'Emax')
plot(e_a);
text(5, e_a(5), 'Ea')
xlabel('latidos')
ylabel('e (mmHg/ml)')
title('Acoplamiento ventrículo-arterial.')