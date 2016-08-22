%% Se importa la informaci�n de las se�ales.
% Script for importing data from the following text file:
%
%    /Users/maximo/Documents/MATLAB/datos_temporales.txt
%
[Qao, Pao] = import_qao_and_pao();




%% Se filtra Pao y Qao

Pao = avg_filter(5, 3, Pao);
Qao = avg_filter(5, 3, Qao);

fs = 250;
samples = length(Pao);
pulse_pressure_a = max(Pao) - min(Pao);


%% Genero t
t = 0:1/fs:(samples-1)/fs;

%% Graficar se�ales temporales puras y puntos caracter�sticos
% Se calculan los m�ximos y m�nimos de las se�ales temporales puras y se
% grafican junto a ellas.

figure
subplot(2,1,1);
vect = Pao;
[location_max, location_min_pao] = get_special_points(vect);
plot(t, vect,'r'); hold on;
xlabel('t(s)')
ylabel('Presi�n (mmHg)')
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min_pao), vect(location_min_pao), '*');
axis([0,t(500), min(vect), max(vect)])
title('Presi�n a�rtica')

subplot(2,1,2);
vect = Qao;
[location_max, location_min_qao] = get_special_points(vect);
plot(t, vect,'r'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min_qao), vect(location_min_qao), '*');
axis([0,t(500), min(vect), max(vect)])
title('Flujo a�rtico')
xlabel('t(s)')
ylabel('Flujo (l/m)')

%% Generaci�n del bucle
% Se obtiene la diferencia de fase entre el m�nimo de presi�n y de
% di�metro. Luego se promedia todos los latidos de di�mentro por un lado y
% presi�n por otro. Finalmente, se elige el ciclo m�s chico (en duraci�n,
% ya sea el ciclo de presi�n o di�metro) y se corta el otro ciclo para que
% coincidan en duraci�n. Finalmente, mediante circshift, se desfasa el di�metro seg�n la
% diferencia de fase obtenida previamente. Finalmente se plotean los ciclos
% promedio obtenidos. Se repite con el flujo.

location_diff = location_min_qao - location_min_pao;
delta_q = median(location_diff);

[avg_pao_beat] = get_avg_beat(Pao);
[avg_qao_beat] = get_avg_beat(Qao);

location_min_avg_pao = last_min(avg_pao_beat);
location_min_avg_qao = last_min(avg_qao_beat);
location_cycle = min(location_min_avg_pao, location_min_avg_qao);
avg_pao_beat = avg_pao_beat(1:location_cycle);
avg_qao_beat = avg_qao_beat(1:location_cycle);
avg_qao_beat = circshift(avg_qao_beat, delta_q);
figure
subplot(2,1,1)
plot(0:1/fs:(length(avg_pao_beat)-1)/fs, avg_pao_beat,'r');
title('Presi�n a�rtica de latido promedio')
xlabel('t(s)')
ylabel('Presi�n (mmHg)')

subplot(2,1,2)
plot(0:1/fs:(length(avg_qao_beat)-1)/fs, avg_qao_beat,'r');
title('Flujo a�rtico de latido promedio')
xlabel('t(s)')
ylabel('Flujo (l/m)')

%% Se calcula el flujo promedio y la presi�n promedio
avg_q = mean(avg_qao_beat);
avg_p = mean(avg_pao_beat);

%% Se calcula la resistencia

r = avg_p/avg_q;
p_diastolic_end = min(avg_pao_beat);
q_max = max(avg_qao_beat);

figure
[~, locations_max] = findpeaks(avg_pao_beat, 'minpeakheight', 0.9*max(avg_pao_beat));
diastolic_start = get_next_min(avg_pao_beat, locations_max(1));
t2_3_d = round(diastolic_start + (length(avg_pao_beat) - diastolic_start)/3);
plot(0:1/fs:(length(avg_pao_beat)-1)/fs, avg_pao_beat,'r'); hold on;
plot(t2_3_d/fs, avg_pao_beat(t2_3_d), '*');
plot(diastolic_start/fs, avg_pao_beat(diastolic_start), 'x');
text(diastolic_start/fs, avg_pao_beat(diastolic_start),'\leftarrow Fin de di�stole')
text(t2_3_d/fs, avg_pao_beat(t2_3_d),'\leftarrow 1/3 de di�stole')
title('Presi�n a�rtica de latido promedio')
xlabel('t(s)')
ylabel('Presi�n (mmHg)')

pp_a = max(avg_pao_beat) - min(avg_pao_beat);
fprintf('Original: Pfs_a = %f, Pfd_a = %f, Rp = %f, Qmax = %f, Presi�n de pulso (PPa) = %f\n', max(avg_pao_beat), min(avg_pao_beat), r, q_max, pp_a);

%% Se calcula la compliance mediante el m�todo de tiempo de decaimiento.

first_third = round(length(avg_pao_beat)/3);
x = diastolic_start/fs:1/fs:(length(avg_pao_beat))/fs;
f = fit(x', avg_pao_beat(diastolic_start:end), 'exp1');
p = coeffvalues(f);
b = p(2);
c = -1/(r*b);
decay_time_compliance = c;
p_fs = get_wk2_ps(avg_pao_beat, r, decay_time_compliance, diastolic_start, fs, q_max, p_diastolic_end);
pulse_pressure_d_decay = p_fs-min(avg_pao_beat);
fprintf('Tiempo de decaimiento: Pfs = %f, Compliance = %f, PPd = %f\n', p_fs, decay_time_compliance, pulse_pressure_d_decay)

%% Se calcula la compliance mediante el m�todo de presi�n de pulso

compliance = decay_time_compliance;
last_compliance = compliance;
delta_c = 0.001;
distance = (get_wk2_pp(avg_pao_beat, r, compliance, diastolic_start, fs, q_max, p_diastolic_end) - pp_a)/pp_a;
last_distance = distance + 1;
while abs(distance) < abs(last_distance)
    last_compliance = compliance;
    compliance = last_compliance - delta_c;
    p_fs = get_wk2_ps(avg_pao_beat, r, compliance, diastolic_start, fs, q_max, p_diastolic_end);
    pp_d = get_wk2_pp(avg_pao_beat, r, compliance, diastolic_start, fs, q_max, p_diastolic_end);
    last_distance = distance;
    distance = (pp_d - pp_a)/pp_a;
%     fprintf('c: %f, p_fs: %f, distance: %f, last_distance: %f\n', compliance, p_fs, distance, last_distance)
end
pulse_pressure_compliance = last_compliance;
pulse_pressure_p_fs = p_fs;
pulse_pressue_pp_d = pp_d;
fprintf('Presi�n de pulso: Pfs = %f, Compliance = %f, PPd = %f\n', pulse_pressure_p_fs, pulse_pressure_compliance, pulse_pressue_pp_d)

%% Se compara la aproximaci�n por WK2 seg�n cada m�todo.

t_s = 0:1/fs:(diastolic_start-1)/fs;
t_d = diastolic_start/fs:1/fs:(length(avg_pao_beat)-1)/fs;
% m�todo de presi�n de pulso
pp_p_sis = (p_diastolic_end - r*q_max)*exp(-t_s/(pulse_pressure_compliance*r)) + r*q_max;
a = pp_p_sis(end);
pp_p_dia = a*exp(-(t_d - t_d(1))/(pulse_pressure_compliance*r));
pp_calculated_pressure = [pp_p_sis pp_p_dia];
% m�todo de tiempo de decaimiento
dt_p_sis = (p_diastolic_end - r*q_max)*exp(-t_s/(decay_time_compliance*r)) + r*q_max;
a = dt_p_sis(end);
dt_p_dia = a*exp(-(t_d - t_d(1))/(decay_time_compliance*r));
dt_calculated_pressure = [dt_p_sis dt_p_dia];
figure
plot([t_s t_d], pp_calculated_pressure); hold on;
plot([t_s t_d], dt_calculated_pressure); hold on;
plot(0:1/fs:(length(avg_pao_beat)-1)/fs, avg_pao_beat,'r');
text(diastolic_start/fs, pp_calculated_pressure(diastolic_start),'\leftarrow PPM')
text(diastolic_start/fs, dt_calculated_pressure(diastolic_start),'\leftarrow DTM')


