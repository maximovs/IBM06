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
Qao = avg_filter(3, 14, Qao);

fs = 250;
samples = length(Pao);

%% Genero t
t = 0:1/fs:(samples-1)/fs;

%% Graficar señales temporales puras y puntos característicos
% Se calculan los máximos y mínimos de las señales temporales puras y se
% grafican junto a ellas.

figure
subplot(2,1,1);
vect = Pao;
[location_max, location_min_pao] = get_special_points(vect);
plot(t, vect,'r'); hold on;
xlabel('t(s)')
ylabel('Presión (mmHg)')
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min_pao), vect(location_min_pao), '*');
axis([0,t(500), min(vect), max(vect)])
title('Presión aórtica')


subplot(2,1,2);
vect = Dao;
[location_max, location_min_dao] = get_special_points(vect);
plot(t, vect,'r'); hold on;
plot(t(location_max), vect(location_max), '*'); hold on;
plot(t(location_min_dao), vect(location_min_dao), '*');
axis([0,t(500), min(vect), max(vect)])
title('Diámetro aórtico')
xlabel('t(s)')
ylabel('Diámetro (mmHg)')

%% Generación del bucle
% Se obtiene la diferencia de fase entre el mínimo de presión y de
% diámetro. Luego se promedia todos los latidos de diámentro por un lado y
% presión por otro. Finalmente, se elige el ciclo más chico (en duración,
% ya sea el ciclo de presión o diámetro) y se corta el otro ciclo para que
% coincidan en duración. Finalmente, mediante circshift, se desfasa el diámetro según la
% diferencia de fase obtenida previamente. Finalmente se plotean los ciclos
% promedio obtenidos.

location_diff = location_min_dao - location_min_pao;
delta = median(location_diff);

[avg_dao_beat] = get_avg_beat(Dao);
[avg_pao_beat] = get_avg_beat(Pao);

location_min_avg_dao = last_min(avg_dao_beat);
location_min_avg_pao = last_min(avg_pao_beat);
location_cycle = min(location_min_avg_pao, location_min_avg_dao);
avg_dao_beat = avg_dao_beat(1:location_cycle);
avg_pao_beat = avg_pao_beat(1:location_cycle);

avg_dao_beat = circshift(avg_dao_beat, delta);

figure
subplot(2,1,1);
plot(0:1/fs:(length(avg_dao_beat)-1)/fs, avg_dao_beat,'r');
title('Diámetro aórtico de latido promedio')
xlabel('t(s)')
ylabel('Diámetro (mmHg)')

subplot(2,1,2)
plot(0:1/fs:(length(avg_pao_beat)-1)/fs, avg_pao_beat,'r');
title('Presión aórtica de latido promedio')
xlabel('t(s)')
ylabel('Presión (mmHg)')

%% Grafico el lazo PD/DA
% Se grafica la presión promedio respecto del diámetro promedio.
figure
plot(avg_dao_beat, avg_pao_beat,'r');
title('Lazo PD/DA promedio')
xlabel('Diámetro (mmHg)')
ylabel('Presión (mmHg)')

%% Obtención de eta y M
% En primer lugar se asume M = 0 y se calcula eta de modo tal que minimice
% el área contenida dentro del lazo PD/DA. Una vez calculado eta, se
% obtiene el valor de M de modo tal que el área contenida dentro del lazo
% PD/DA se minimice aún más. Finalmente, se aproxima una recta a los puntos
% del lazo luego de restarle eta*dD/dt y M*d2D/dt. Así, mediante polyfit,
% se obtiene E.

% Se calculo la derivada primera y segunda del diámetro en función del tiempo
% del latido promedio y luego se filtran.
dD_dt = get_diff(avg_dao_beat)*fs;
dD_dt = avg_filter(5, 3, dD_dt);
d2D_dt = get_diff(dD_dt);
d2D_dt = avg_filter(5, 3, d2D_dt);
% subplot(2,1,1);
% plot(avg_dao_beat,'r');
% Se obtiene el valor de eta de modo tal que minimice el área mediante la
% función get_multiplier pasando como parámetros el lazo y la derivada del
% diámetro en función del tiempo.
vect = join(avg_dao_beat, avg_pao_beat);
eta = get_multiplier(vect, dD_dt);

vect_with_eta = vect - [zeros(length(dD_dt),1) eta*dD_dt];

figure
subplot(1,2,1);
plot(vect_with_eta(:,1), vect_with_eta(:,2), 'r')
title('Lazo PD/DA promedio - eta*dD/dt')
xlabel('Diámetro (mmHg)')
ylabel('Presión (mmHg)')

% Una vez obtenida eta, se hace lo mismo para obtener M. Primero se resta
% eta al lazo y luego se obtiene M mediante get_multiplier pasando como
% parámetros el lazo y la derivada del diámetro en función del tiempo.

m = get_multiplier(vect_with_eta, d2D_dt);
complete_vect = vect_with_eta - [zeros(length(d2D_dt),1) m*d2D_dt];

subplot(1,2,2);
plot(complete_vect(:,1), complete_vect(:,2), 'r')
title('Lazo PD/DA promedio - eta*dD/dt - M*d2D/dt')
xlabel('Diámetro (mmHg)')
ylabel('Presión (mmHg)')

%% Obtención de E
% Una vez obtenidos eta y M se calcula E de modo que la recta aproxime de
% la mejor manera la nube de puntos
figure
p_el = polyfit(complete_vect(:,1), complete_vect(:,2),1);
ajuste = complete_vect(:,2) - vect(:,2);
p_el_values = polyval(p_el,complete_vect(:,1));
res = p_el_values - ajuste;
subplot(1,2,1);
plot(complete_vect(:,1), res);
title('Lazo PD/DA generado: E(t) - eta*dD/dt - M*d2D/dt')
xlabel('Diámetro (mmHg)')
ylabel('Presión (mmHg)')

subplot(1,2,2);
plot(avg_dao_beat, avg_pao_beat,'r');
title('Lazo PD/DA promedio')
xlabel('Diámetro (mmHg)')
ylabel('Presión (mmHg)')

fprintf('E: %1.4f, eta: %1.4f, M: %1.4f',p_el(1), eta, m);
