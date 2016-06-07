%% Se importa la información
% Para importar la información se utiliza ImportData de Matlab para que
% autogenere la función importfile.

[PRES,DIAM,VIA1,VIA2,VIA3,VIA4] = importfile('datos_temporalesII.txt',8, 2007);

%% Se filtra y normaliza la información
pao = avg_filter(5, 3, PRES);
dao = avg_filter(5, 3, DIAM);
v1 = avg_filter(5, 3, VIA1);
v2 = avg_filter(5, 3, VIA2);
v3 = avg_filter(5, 3, VIA4);
fs = 250;
t = 0:1/fs:(length(pao)-1)/fs;
pao = pao*0.000750061561303;%Asumo los datos en kPa

%% Se calculan los valores de D, P y V en un latido promedio.
[~, location_min_dao] = get_special_points(dao);
[~, location_min_pao] = get_special_points(pao);
[~, location_min_v1] = get_special_points(v1);
[~, location_min_v2] = get_special_points(v2);
[~, location_min_v3] = get_special_points(v3);

[avg_dao_beat] = get_avg_beat(dao);
[avg_pao_beat] = get_avg_beat(pao);
[avg_v1_beat] = get_avg_beat(v1);
[avg_v2_beat] = get_avg_beat(v2);
[avg_v3_beat] = get_avg_beat(v3);
% Normalizo las mediciones de los latidos promedio
l = min([length(avg_dao_beat), length(avg_pao_beat), length(avg_v1_beat), length(avg_v2_beat), length(avg_v3_beat)]);
avg_dao_beat = avg_dao_beat(1:l);
avg_pao_beat = avg_pao_beat(1:l);
avg_v1_beat = avg_v1_beat(1:l);
avg_v2_beat = avg_v2_beat(1:l);
avg_v3_beat = avg_v3_beat(1:l);

% Pongo en fase los latidos promedio.
location_diff = location_min_dao - location_min_pao;
delta_d = round(median(location_diff));
avg_dao_beat = circshift(avg_dao_beat, delta_d);
location_diff = location_min_v1 - location_min_pao;
delta_d = round(median(location_diff));
avg_v1_beat = circshift(avg_v1_beat, delta_d);
location_diff = location_min_v2 - location_min_pao;
delta_d = round(median(location_diff));
avg_v2_beat = circshift(avg_v2_beat, delta_d);
location_diff = location_min_v3 - location_min_pao;
delta_d = round(median(location_diff));
avg_v3_beat = circshift(avg_v3_beat, delta_d);

% Filtro los latidos promedio
avg_pao_beat = avg_filter(5, 3, avg_pao_beat);
avg_dao_beat = avg_filter(5, 3, avg_dao_beat);
avg_v1_beat = avg_filter(5, 3, avg_v1_beat);
avg_v2_beat = avg_filter(5, 3, avg_v2_beat);
avg_v3_beat = avg_filter(5, 3, avg_v3_beat);

%% Se imprimen las señales biológicas en latido promedio.
plot_beat(avg_pao_beat, fs, 't(s)', 'Presión (mmHg)', 'Presión aórtica');
plot_beat(avg_dao_beat, fs, 't(s)', 'Diámetro (cm)', 'Diámetro aórtica');
plot_beat(avg_v1_beat, fs, 't(s)', 'Velocidad (cm/s)', 'Velocidad 1 aórtica');
plot_beat(avg_v2_beat, fs, 't(s)', 'Velocidad (cm/s)', 'Velocidad 2 aórtica');
plot_beat(avg_v3_beat, fs, 't(s)', 'Velocidad (cm/s)', 'Velocidad 3 aórtica');

%% Calculo los perfiles de velocidad en un latido promedio.
%Se obtiene el perfil de velocidad instante a instante a lo largo del
%latido y se lo imprime. Para ver el avance en el tiempo, se agrega una
%pausa con la velocidad de muestreo.
figure
for i = 1:length(avg_v1_beat)
    [x, y] = get_perfil(i, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
    plot(x, y);
%     pause(1.0/125)
end

%% Se generan matrices de diámetro en función del tiempo y velocidad en función del tiempo
%Para cada instante se calcula la velocidad en cada parte de la arteria y
%se la agrega a la matriz. A su vez se agrega a la matriz de diámetro el
%tamaño de la arteria en cada momento y la separación de vn-vn+1 en cada
%instante.

diam = zeros(length(avg_v1_beat), 5);
velo = zeros(length(avg_v1_beat), 5);
for i = 1:length(avg_v1_beat)
    [x, y] = get_perfil(i, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
    diam(i, :) = x(:);
    velo(i, :) = y(:);
end

%% Se genera gráfico 3D representando la velocidad y el diámetro en función del tiempo
%Con las matrices calculadas en el punto anterior se grafica utilizando la
%función surf.
t = 0:1/fs:(length(avg_v1_beat)-1)/fs;
figure
surf(t', diam', velo');

%% Se calcula en los momentos destacados una aproximación del perfil de velocidad.
%En cada instante se obtiene el perfil de velocidad con get_perfil y a
%partir de él se ajustan los valores utilizando polyfit con grado 2. Se
%repite para todos los instantes importantes.
[~, inicio_sistole] = max(avg_pao_beat);
[~, fin_diastole] = min(avg_pao_beat);
inicio_diastole = get_zero_point(avg_pao_beat);
[d_min, diam_minimo] = min(avg_dao_beat);
[d_max, diam_maximo] = max(avg_dao_beat);

plot_fit(inicio_sistole, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
plot_fit(inicio_diastole, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
plot_fit(fin_diastole, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
plot_fit(diam_minimo, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
plot_fit(diam_maximo, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);

