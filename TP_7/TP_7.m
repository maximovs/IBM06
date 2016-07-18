%% Importo los datos
% Se utiliza la función autogenerada por Matlab
[PVI, PVD, VVIendo, VVDendo] = read_data();

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
figure
subplot(2,1,1)
vect = PVI;
[location_max, location_min] = get_special_points(vect);
[loc_10_p, loc_10_n] = get_ios_and_eod(vect, 0.11);
pfs_i = PVI(loc_10_n);
vfs_i = VVI(loc_10_n);
plot(t, vect,'r'); hold on;
plot(t, get_diff(vect),'b'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min), vect(location_min), '*');
plot(t(loc_10_p), vect(loc_10_p), 'x'); hold on;
text(t(loc_10_p), vect(loc_10_p),'\leftarrow Inicio de sístole')
plot(t(loc_10_n), vect(loc_10_n), 'o'); hold on;
text(t(loc_10_n), vect(loc_10_n),'\leftarrow Fin de sístole')
xlabel('t (s)')
ylabel('p (mmHg)')
title('Presión del ventrículo izquierdo.')
subplot(2,1,2)
vect = VVI;
[location_max, location_min] = get_special_points(vect);
plot(t, vect,'r'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min), vect(location_min), '*');
xlabel('t (s)')
ylabel('v (ml)')
title('Volumen del ventrículo izquierdo.')
figure
subplot(2,1,1)
vect = PVD;
[location_max, location_min] = get_special_points(vect);
[loc_10_p, loc_10_n] = get_ios_and_eod(vect, 0.11);
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
subplot(2,1,2)
vect = VVD;
[location_max, location_min] = get_special_points(vect);
plot(t, vect,'r'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min), vect(location_min), '*');
xlabel('t (s)')
ylabel('v (ml)')
title('Volumen del ventrículo derecho.')


%% Lazo PV - VV de ambos ventrículos

figure
p = polyfit(vfs_d, pfs_d, 1);
d = 35:0.01:max(VVD);
y1 = polyval(p, d);
v0_d = -p(2)/p(1);
plot(d, y1); hold on;
plot(vfs_d, pfs_d, '*'); hold on;
plot(VVD, PVD);
title('Bucle del ventrículo derecho.')

figure
p = polyfit(vfs_i, pfs_i, 1);
d = 40:0.01:max(VVI);
y1 = polyval(p, d);
v0_i = -p(2)/p(1);
plot(d, y1); hold on;
plot(vfs_i, pfs_i, '*'); hold on;
plot(VVI, PVI);
title('Bucle del ventrículo izquierdo.')
figure
e_d = PVD./(VVD-v0_d);
E_min = ones(length(t),1) .* max(e_d);
E_max = ones(length(t),1) .* min(e_d);
plot(t, E_min); hold on;
plot(t, E_max); hold on;
c_d = 1./e_d;
% c_d = avg_filter(8, 5, c_d);
avg_c = median(c_d);
for i=1:length(c_d)
    if c_d(i) > 100* avg_c
        c_d(i) = c_d(i-1);
    end
end
plotyy(t, e_d, t, c_d)
xlabel('t (s)')
ylabel('e (mmHg/ml)')
title('Elastancia del ventrículo derecho.')

figure
e_i = PVI./(VVI-v0_i);
E_min = ones(length(t),1) .* max(e_i);
E_max = ones(length(t),1) .* min(e_i);
plot(t, E_min); hold on;
plot(t, E_max); hold on;
plot(t, e_i)
xlabel('t (s)')
ylabel('e (mmHg/ml)')
title('Elastancia del ventrículo izquierdo.')
