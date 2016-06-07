%% Se importa la información
% Para importar la información se utiliza ImportData de Matlab para que
% autogenere la función importfile.

[PRES,DIAM,VIA1,VIA2,VIA3,VIA4] = importfile('datos_temporalesII.txt',8, 2007);

pao = avg_filter(5, 3, PRES);
dao = avg_filter(5, 3, DIAM);
v1 = avg_filter(5, 3, VIA1);
v2 = avg_filter(5, 3, VIA2);
v3 = avg_filter(5, 3, VIA4);
fs = 250;
t = 0:1/fs:(length(pao)-1)/fs;
pao = pao*0.000750061561303;%Asumo los datos en kPa

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
l = min([length(avg_dao_beat), length(avg_pao_beat), length(avg_v1_beat), length(avg_v2_beat), length(avg_v3_beat)]);
avg_dao_beat = avg_dao_beat(1:l);
avg_pao_beat = avg_pao_beat(1:l);
avg_v1_beat = avg_v1_beat(1:l);
avg_v2_beat = avg_v2_beat(1:l);
avg_v3_beat = avg_v3_beat(1:l);

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

avg_pao_beat = avg_filter(5, 3, avg_pao_beat);
avg_dao_beat = avg_filter(5, 3, avg_dao_beat);
avg_v1_beat = avg_filter(5, 3, avg_v1_beat);
avg_v2_beat = avg_filter(5, 3, avg_v2_beat);
avg_v3_beat = avg_filter(5, 3, avg_v3_beat);

plot_beat(avg_pao_beat, fs, 't(s)', 'Presión (mmHg)', 'Presión aórtica media');
plot_beat(avg_dao_beat, fs, 't(s)', 'Diámetro (cm)', 'Diámetro aórtica media');
plot_beat(avg_v1_beat, fs, 't(s)', 'Velocidad (cm/s)', 'Velocidad 1 aórtica media');
plot_beat(avg_v2_beat, fs, 't(s)', 'Velocidad (cm/s)', 'Velocidad 2 aórtica media');
plot_beat(avg_v3_beat, fs, 't(s)', 'Velocidad (cm/s)', 'Velocidad 3 aórtica media');

figure
for i = 1:length(avg_v1_beat)
    [x, y] = get_perfil(i, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
    plot(x, y);
%     pause(0.1)
end
diam = zeros(length(avg_v1_beat), 5);
velo = zeros(length(avg_v1_beat), 5);
for i = 1:length(avg_v1_beat)
    [x, y] = get_perfil(i, avg_v1_beat, avg_v2_beat, avg_v3_beat, avg_dao_beat);
    diam(i, :) = x(:);
    velo(i, :) = y(:);
end

figure
subplot(3,1,1)
plot(avg_dao_beat, avg_v1_beat);
subplot(3,1,2)
plot(avg_dao_beat, avg_v2_beat);
subplot(3,1,3)
plot(avg_dao_beat, avg_v3_beat);
t = 0:1/fs:(length(avg_v1_beat)-1)/fs;
figure
surf(t', diam', velo');
