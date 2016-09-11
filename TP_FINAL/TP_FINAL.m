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
location_p_max = locations_max(1);
diastolic_start = get_next_min(avg_pao_beat, locations_max(1));
t2_3_d = round(diastolic_start + (length(avg_pao_beat) - diastolic_start)/3);
plot(0:1/fs:(length(avg_pao_beat)-1)/fs, avg_pao_beat,'r'); hold on;
plot(t2_3_d/fs, avg_pao_beat(t2_3_d), '*');
plot(diastolic_start/fs, avg_pao_beat(diastolic_start), 'x');
text(diastolic_start/fs, avg_pao_beat(diastolic_start),'\leftarrow Inicio de di�stole')
text(t2_3_d/fs, avg_pao_beat(t2_3_d),'\leftarrow 1/3 de di�stole')
title('Presi�n a�rtica de latido promedio')
xlabel('t(s)')
ylabel('Presi�n (mmHg)')

pp_a = max(avg_pao_beat) - min(avg_pao_beat);
fprintf('Original: Pfs_a = %f, Pfd_a = %f, Rp = %f, Qmax = %f, Presi�n de pulso (PPa) = %f, Presi�n media: %f\n', max(avg_pao_beat), min(avg_pao_beat), r, q_max, pp_a, mean(avg_pao_beat));

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
title('Comparaci�n de ambos m�todos utilizados en el paper')
xlabel('t(s)')
ylabel('Presi�n (mmHg)')
%% Metodolog�a propuesta por nosotros original
% En lugar de partir las funciones en s�stole y di�stole tomando en cuenta
% el punto medio como el inicio de di�stole, se puede aproximar tomando
% como punto medio la presi�n m�xima. Si bien esto no resultar�a en una
% aproximaci�n fisiol�gica certera, la utilizada previamente tampoco lo es
% y permite una aproximaci�n mayor a la presi�n en funci�n del tiempo
% original.

[modified_pulse_pressure_compliance, modified_pulse_pressure_p_fs, modified_pulse_pressue_pp_d] = get_compliance_via_ppm(avg_pao_beat, r, compliance, location_p_max, fs, q_max, p_diastolic_end, pp_a);
fprintf('Modificaci�n original propuesta de presi�n de pulso: Pfs = %f, Compliance = %f, PPd = %f\n', modified_pulse_pressure_p_fs, modified_pulse_pressure_compliance, modified_pulse_pressue_pp_d)

modified_t_s = 0:1/fs:(location_p_max-1)/fs;
modified_t_d = location_p_max/fs:1/fs:(length(avg_pao_beat)-1)/fs;
% m�todo propuesto por nosotros
modified_pp_p_sis = (p_diastolic_end - r*q_max)*exp(-modified_t_s/(modified_pulse_pressure_compliance*r)) + r*q_max;
a = modified_pp_p_sis(end);
modified_pp_p_dia = a*exp(-(modified_t_d - modified_t_d(1))/(modified_pulse_pressure_compliance*r));
modified_pp_calculated_pressure = [modified_pp_p_sis modified_pp_p_dia];

%% Metodolog�a propuesta por nosotros alternativa
% A diferencia de nuestra propuesta original, por medio de ensayo y error
% descubrimos que tomando el fin de s�stole como 3/7 del ciclo, se obtiene
% una funci�n muy aproximada a la original.
sistolic_end = ceil(3*length(avg_pao_beat)/7);
[alternative_pulse_pressure_compliance, alternative_pulse_pressure_p_fs, alternative_pulse_pressue_pp_d] = get_compliance_via_ppm(avg_pao_beat, r, compliance, sistolic_end, fs, q_max, p_diastolic_end, pp_a);
fprintf('Modificaci�n alternativa propuesta de presi�n de pulso: Pfs = %f, Compliance = %f, PPd = %f\n', alternative_pulse_pressure_p_fs, alternative_pulse_pressure_compliance, alternative_pulse_pressue_pp_d)

alternative_t_s = 0:1/fs:(sistolic_end-1)/fs;
alternative_t_d = sistolic_end/fs:1/fs:(length(avg_pao_beat)-1)/fs;
% m�todo alternativo propuesto por nosotros
alternative_pp_p_sis = (p_diastolic_end - r*q_max)*exp(-alternative_t_s/(alternative_pulse_pressure_compliance*r)) + r*q_max;
a = alternative_pp_p_sis(end);
alternative_pp_p_dia = a*exp(-(alternative_t_d - alternative_t_d(1))/(alternative_pulse_pressure_compliance*r));
alternative_pp_calculated_pressure = [alternative_pp_p_sis alternative_pp_p_dia];
figure
plot([t_s t_d], pp_calculated_pressure); hold on;
plot([t_s t_d], dt_calculated_pressure); hold on;
plot([t_s t_d], modified_pp_calculated_pressure); hold on;
plot([t_s t_d], alternative_pp_calculated_pressure); hold on;
plot(0:1/fs:(length(avg_pao_beat)-1)/fs, avg_pao_beat,'r');
text(diastolic_start/fs, pp_calculated_pressure(diastolic_start),'\leftarrow PPM')
text(diastolic_start/fs, dt_calculated_pressure(diastolic_start),'\leftarrow DTM')
text(location_p_max/fs, modified_pp_calculated_pressure(location_p_max),'\leftarrow MPPM')
text(sistolic_end/fs, alternative_pp_calculated_pressure(sistolic_end),'\leftarrow APPM')
title('Comparaci�n entre los m�todos del paper y las alternativas propuestas')
xlabel('t(s)')
ylabel('Presi�n (mmHg)')
%% Metodolog�a propuesta por nosotros alternativa en otra se�al
% A diferencia de nuestra propuesta original, por medio de ensayo y error
% descubrimos que tomando el fin de s�stole como 3/7 del ciclo, se obtiene
% una funci�n muy aproximada a la original.
[avg_pao_beat2, avg_qao_beat2, r2] = get_TP_3_data();
pp_a2 = max(avg_pao_beat2) - min(avg_pao_beat2);
sistolic_end = ceil(3*length(avg_pao_beat2)/7);
[alternative_pulse_pressure_compliance2, alternative_pulse_pressure_p_fs2, alternative_pulse_pressue_pp_d2] = get_compliance_via_ppm(avg_pao_beat2, r2, compliance, sistolic_end, fs, max(avg_qao_beat2), min(avg_pao_beat2), pp_a2);
fprintf('Modificaci�n alternativa propuesta de presi�n de pulso: Pfs = %f, Compliance = %f, PPd = %f\n', alternative_pulse_pressure_p_fs2, alternative_pulse_pressure_compliance2, alternative_pulse_pressue_pp_d2)

alternative_t_s2 = 0:1/fs:(sistolic_end-1)/fs;
alternative_t_d2 = sistolic_end/fs:1/fs:(length(avg_pao_beat2)-1)/fs;
% m�todo alternativo propuesto por nosotros
alternative_pp_p_sis2 = (min(avg_pao_beat2) - r2*max(avg_qao_beat2))*exp(-alternative_t_s2/(alternative_pulse_pressure_compliance2*r2)) + r2*max(avg_qao_beat2);
a = alternative_pp_p_sis2(end);
alternative_pp_p_dia2 = a*exp(-(alternative_t_d2 - alternative_t_d2(1))/(alternative_pulse_pressure_compliance2*r2));
alternative_pp_calculated_pressure2 = [alternative_pp_p_sis2 alternative_pp_p_dia2];

figure
plot([alternative_t_s2 alternative_t_d2], alternative_pp_calculated_pressure2); hold on;
plot(0:1/fs:(length(avg_pao_beat2)-1)/fs, avg_pao_beat2,'r');
text(sistolic_end/fs, alternative_pp_calculated_pressure2(sistolic_end),'\leftarrow APPM')
title('An�lisis del resultado con la alternativa propuesta en otro conjunto de datos')
xlabel('t(s)')
ylabel('Presi�n (mmHg)')

%% Pruebas en se�ales de humanos provistas por la c�tedra
%Se escoge 2 sujetos del conjunto de se�ales de presi�n y flujo y se los
%utiliza para correr las mismas pruebas que con el resto de las se�ales
%utilizadas previamente.

load('AORTA_ROOT_physio.mat');
subject2 = AORTA_ROOT_PHYSIO{1,2}.ONE_CYCLE(:,2:3);
subject4 = AORTA_ROOT_PHYSIO{1,4}.ONE_CYCLE(:,2:3);
%Se normaliza los datos para que mantengan las unidades utilizadas.
Pao2 = double(subject2(:,1)*0.007501);
Pao4 = double(subject4(:,1)*0.007501);
Qao2 = double(subject2(:,2)*1000*60);
Qao4 = double(subject4(:,2)*1000*60);
fs_2 = 1000;

calculate_all_methods_and_variables(Pao2, Qao2, fs_2,'Subject 2');
calculate_all_methods_and_variables(Pao4, Qao4, fs_2, 'Subject 4');

%% Prueba con la se�al utilizada por el paper
%Se intenta aproximar la funci�n utilizada por el paper a partir de los
%gr�ficos presentados por el mismo. Una vez obtenidos los puntos m�s
%importantes, se utiliza una funci�n para normalizarlo y muestrearla a
%250Hz. Con estos resultados se ejecutan todas las pruebas que fueron
%ejecutadas en el resto de las funciones.

load('flow_and_pressure_paper.mat')
Pao_paper = Ppaper(:,2);
Qao_paper = Qpaper(:,2);
calculate_all_methods_and_variables(Pao_paper, Qao_paper, fs, 'Paper data');

