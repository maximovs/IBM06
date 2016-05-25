%% Se importa la información de las señales.
% Script for importing data from the following text file:
%
%    /Users/maximo/Documents/MATLAB/datos_temporales.txt
%

filename = '/Users/maximo/Documents/MATLAB/IBM06/TP_2/datos_temporales.txt';
delimiter = '\t';
startRow = 5;

formatSpec = '%f%f%f%f%[^\n\r]';

fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

fclose(fileID);

ECG = dataArray{:, 1};
Pao = dataArray{:, 2};
Dao = dataArray{:, 3};
Qao = dataArray{:, 4};

clearvars filename delimiter startRow formatSpec fileID dataArray ans;


%% Se filtra ECG, Pao, Dao, Qao
ECG = -ECG;
ECG = avg_filter(3, 8, ECG);
Pao = avg_filter(5, 3, Pao);
Dao = avg_filter(5, 3, Dao);
Qao = avg_filter(5, 3, Qao);

fs = 250;
samples = length(Pao);

%% Genero t
t = 0:1/fs:(samples-1)/fs;

%% Graficar señales temporales puras y puntos característicos
% Se calculan los máximos y mínimos de las señales temporales puras y se
% grafican junto a ellas.

figure
subplot(3,1,1);
vect = Pao;
[location_max, location_min_pao] = get_special_points(vect);
plot(t, vect,'r'); hold on;
xlabel('t(s)')
ylabel('Presión (mmHg)')
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min_pao), vect(location_min_pao), '*');
axis([0,t(500), min(vect), max(vect)])
title('Presión aórtica')


subplot(3,1,2);
vect = Dao;
[location_max, location_min_dao] = get_special_points(vect);
plot(t, vect,'r'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min_dao), vect(location_min_dao), '*');
axis([0,t(500), min(vect), max(vect)])
title('Diámetro aórtico')
xlabel('t(s)')
ylabel('Diámetro (mmHg)')

subplot(3,1,3);
vect = Qao;
[location_max, location_min_qao] = get_special_points(vect);
plot(t, vect,'r'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min_qao), vect(location_min_qao), '*');
axis([0,t(500), min(vect), max(vect)])
title('Flujo aórtico')
xlabel('t(s)')
ylabel('Flujo (l/m)')

%% Generación del bucle
% Se obtiene la diferencia de fase entre el mínimo de presión y de
% diámetro. Luego se promedia todos los latidos de diámentro por un lado y
% presión por otro. Finalmente, se elige el ciclo más chico (en duración,
% ya sea el ciclo de presión o diámetro) y se corta el otro ciclo para que
% coincidan en duración. Finalmente, mediante circshift, se desfasa el diámetro según la
% diferencia de fase obtenida previamente. Finalmente se plotean los ciclos
% promedio obtenidos. Se repite con el flujo.

location_diff = location_min_dao - location_min_pao;
delta_d = median(location_diff);
location_diff = location_min_qao - location_min_pao;
delta_q = median(location_diff);

[avg_dao_beat] = get_avg_beat(Dao);
[avg_pao_beat] = get_avg_beat(Pao);
[avg_qao_beat] = get_avg_beat(Qao);

location_min_avg_dao = last_min(avg_dao_beat);
location_min_avg_pao = last_min(avg_pao_beat);
location_min_avg_qao = last_min(avg_qao_beat);
location_cycle = min([location_min_avg_pao, location_min_avg_dao, location_min_avg_qao]);
avg_dao_beat = avg_dao_beat(1:location_cycle);
avg_pao_beat = avg_pao_beat(1:location_cycle);
avg_qao_beat = avg_qao_beat(1:location_cycle);

avg_dao_beat = circshift(avg_dao_beat, delta_d);
avg_qao_beat = circshift(avg_qao_beat, delta_q);

figure
subplot(3,1,1);
plot(0:1/fs:(length(avg_dao_beat)-1)/fs, avg_dao_beat,'r');
title('Diámetro aórtico de latido promedio')
xlabel('t(s)')
ylabel('Diámetro (mmHg)')

subplot(3,1,2)
plot(0:1/fs:(length(avg_pao_beat)-1)/fs, avg_pao_beat,'r');
title('Presión aórtica de latido promedio')
xlabel('t(s)')
ylabel('Presión (mmHg)')

subplot(3,1,3)
plot(0:1/fs:(length(avg_qao_beat)-1)/fs, avg_qao_beat,'r');
title('Flujo aórtico de latido promedio')
xlabel('t(s)')
ylabel('Flujo (l/m)')

%% Se calcula el flujo promedio y la presión promedio
avg_q = mean(avg_qao_beat);
avg_p = mean(avg_pao_beat);

r = avg_q/avg_p;
figure
[~, locations_max] = findpeaks(avg_pao_beat, 'minpeakheight', 0.8*max(avg_pao_beat));
diastolic_start = get_next_min(avg_pao_beat, locations_max(1));
t2_3_d = round(diastolic_start + (length(avg_pao_beat) - diastolic_start)/3);
plot(0:1/fs:(length(avg_pao_beat)-1)/fs, avg_pao_beat,'r'); hold on;
plot(t2_3_d/fs, avg_pao_beat(t2_3_d), '*');
title('Presión aórtica de latido promedio')
xlabel('t(s)')
ylabel('Presión (mmHg)')

%% Se calculan los parámetros restantes

first_third = round(length(avg_pao_beat)/3);
x = diastolic_start/fs:1/fs:(length(avg_pao_beat))/fs;
f = fit(x', avg_pao_beat(diastolic_start:end), 'exp1');
p = coeffvalues(f);
a = p(1);
b = p(2);
c = -1/(r*b);
p_diastolic_end = min(avg_pao_beat);
q_max = max(avg_qao_beat);

fprintf('Qmax = %f, Pfd = %f, Rp = %f, Ca = %f, Pfs = %f', q_max, p_diastolic_end, r, c, a)



