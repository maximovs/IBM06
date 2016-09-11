function [ aux ] = calculate_all_methods_and_variables( Pao, Qao, fs, titulo )
t = 0:1/fs:(length(Pao)-1)/fs;

figure
subplot(2,1,1);
vect = Pao;
plot(t, vect,'r'); hold on;
xlabel('t(s)')
ylabel('Presión (mmHg)')
axis([0,t(end), min(vect), max(vect)])
title(['(' titulo ') Presión aórtica'])

subplot(2,1,2);
vect = Qao;
plot(t, vect,'r'); hold on;
axis([0,t(end), min(vect), max(vect)])
title(['(' titulo ') Flujo aórtico'])
xlabel('t(s)')
ylabel('Flujo (l/m)')

%% Se calcula el flujo promedio y la presión promedio
avg_q = mean(Qao);
avg_p = mean(Pao);



%% Se calcula la resistencia

r = avg_p/avg_q;
p_diastolic_end = min(Pao);
q_max = max(Qao);

figure
[~, locations_max] = findpeaks(Pao, 'minpeakheight', 0.9*max(Pao));
location_p_max = locations_max(1);
diastolic_start = get_next_min(Pao, locations_max(1));
t2_3_d = round(diastolic_start + (length(Pao) - diastolic_start)/3);
plot(0:1/fs:(length(Pao)-1)/fs, Pao,'r'); hold on;
plot(t2_3_d/fs, Pao(t2_3_d), '*');
plot(diastolic_start/fs, Pao(diastolic_start), 'x');
text(diastolic_start/fs, Pao(diastolic_start),'\leftarrow Inicio de diástole')
text(t2_3_d/fs, Pao(t2_3_d),'\leftarrow 1/3 de diástole')
title(['(' titulo ') Presión aórtica de latido promedio'])
xlabel('t(s)')
ylabel('Presión (mmHg)')

pp_a = max(Pao) - min(Pao);
fprintf(['(' titulo ') Original: Pfs_a = %f, Pfd_a = %f, Rp = %f, Qmax = %f, Presión de pulso (PPa) = %f, Presión media: %f\n'], max(Pao), min(Pao), r, q_max, pp_a, mean(Pao));

%% Se calcula la compliance mediante el método de tiempo de decaimiento.

first_third = round(length(Pao)/3);
x = diastolic_start/fs:1/fs:(length(Pao))/fs;
f = fit(x', Pao(diastolic_start:end), 'exp1');
p = coeffvalues(f);
b = p(2);
c = -1/(r*b);
decay_time_compliance = c;
p_fs = get_wk2_ps(Pao, r, decay_time_compliance, diastolic_start, fs, q_max, p_diastolic_end);
pulse_pressure_d_decay = p_fs-min(Pao);
fprintf(['(' titulo ') Tiempo de decaimiento: Pfs = %f, Compliance = %f, PPd = %f\n'], p_fs, decay_time_compliance, pulse_pressure_d_decay)

%% Se calcula la compliance mediante el método de presión de pulso

compliance = decay_time_compliance;
last_compliance = compliance;
delta_c = 0.001;
distance = (get_wk2_pp(Pao, r, compliance, diastolic_start, fs, q_max, p_diastolic_end) - pp_a)/pp_a;
next_distance = (get_wk2_pp(Pao, r, compliance - delta_c, diastolic_start, fs, q_max, p_diastolic_end) - pp_a)/pp_a;
if abs(next_distance) > abs(distance)
    delta_c = delta_c * -1;
end
last_distance = distance + 1;
while abs(distance) < abs(last_distance)
    last_compliance = compliance;
    compliance = last_compliance - delta_c;
    p_fs = get_wk2_ps(Pao, r, compliance, diastolic_start, fs, q_max, p_diastolic_end);
    pp_d = get_wk2_pp(Pao, r, compliance, diastolic_start, fs, q_max, p_diastolic_end);
    last_distance = distance;
    distance = (pp_d - pp_a)/pp_a;
%     fprintf('c: %f, p_fs: %f, distance: %f, last_distance: %f\n', compliance, p_fs, distance, last_distance)
end
pulse_pressure_compliance = last_compliance;
pulse_pressure_p_fs = p_fs;
pulse_pressue_pp_d = pp_d;
fprintf(['(' titulo ') Presión de pulso: Pfs = %f, Compliance = %f, PPd = %f\n'], pulse_pressure_p_fs, pulse_pressure_compliance, pulse_pressue_pp_d)

%% Se compara la aproximación por WK2 según cada método.

t_s = 0:1/fs:(diastolic_start-1)/fs;
t_d = diastolic_start/fs:1/fs:(length(Pao)-1)/fs;
% método de presión de pulso
pp_p_sis = (p_diastolic_end - r*q_max)*exp(-t_s/(pulse_pressure_compliance*r)) + r*q_max;
a = pp_p_sis(end);
pp_p_dia = a*exp(-(t_d - t_d(1))/(pulse_pressure_compliance*r));
pp_calculated_pressure = [pp_p_sis pp_p_dia];
% método de tiempo de decaimiento
dt_p_sis = (p_diastolic_end - r*q_max)*exp(-t_s/(decay_time_compliance*r)) + r*q_max;
a = dt_p_sis(end);
dt_p_dia = a*exp(-(t_d - t_d(1))/(decay_time_compliance*r));
dt_calculated_pressure = [dt_p_sis dt_p_dia];
figure
plot([t_s t_d], pp_calculated_pressure); hold on;
plot([t_s t_d], dt_calculated_pressure); hold on;
plot(0:1/fs:(length(Pao)-1)/fs, Pao,'r');
text(diastolic_start/fs, pp_calculated_pressure(diastolic_start),'\leftarrow PPM')
text(diastolic_start/fs, dt_calculated_pressure(diastolic_start),'\leftarrow DTM')
title(['(' titulo ') Comparación de ambos métodos utilizados en el paper'])
xlabel('t(s)')
ylabel('Presión (mmHg)')
%% Metodología propuesta por nosotros original
% En lugar de partir las funciones en sístole y diástole tomando en cuenta
% el punto medio como el inicio de diástole, se puede aproximar tomando
% como punto medio la presión máxima. Si bien esto no resultaría en una
% aproximación fisiológica certera, la utilizada previamente tampoco lo es
% y permite una aproximación mayor a la presión en función del tiempo
% original.

[modified_pulse_pressure_compliance, modified_pulse_pressure_p_fs, modified_pulse_pressue_pp_d] = get_compliance_via_ppm(Pao, r, compliance, location_p_max, fs, q_max, p_diastolic_end, pp_a);
fprintf(['(' titulo ') Modificación original propuesta de presión de pulso: Pfs = %f, Compliance = %f, PPd = %f\n'], modified_pulse_pressure_p_fs, modified_pulse_pressure_compliance, modified_pulse_pressue_pp_d)

modified_t_s = 0:1/fs:(location_p_max-1)/fs;
modified_t_d = location_p_max/fs:1/fs:(length(Pao)-1)/fs;
% método propuesto por nosotros
modified_pp_p_sis = (p_diastolic_end - r*q_max)*exp(-modified_t_s/(modified_pulse_pressure_compliance*r)) + r*q_max;
a = modified_pp_p_sis(end);
modified_pp_p_dia = a*exp(-(modified_t_d - modified_t_d(1))/(modified_pulse_pressure_compliance*r));
modified_pp_calculated_pressure = [modified_pp_p_sis modified_pp_p_dia];

%% Metodología propuesta por nosotros alternativa
% A diferencia de nuestra propuesta original, por medio de ensayo y error
% descubrimos que tomando el fin de sístole como 3/7 del ciclo, se obtiene
% una función muy aproximada a la original.
sistolic_end = ceil(3*length(Pao)/7);
[alternative_pulse_pressure_compliance, alternative_pulse_pressure_p_fs, alternative_pulse_pressue_pp_d] = get_compliance_via_ppm(Pao, r, compliance, sistolic_end, fs, q_max, p_diastolic_end, pp_a);
fprintf(['(' titulo ') Modificación alternativa propuesta de presión de pulso: Pfs = %f, Compliance = %f, PPd = %f\n'], alternative_pulse_pressure_p_fs, alternative_pulse_pressure_compliance, alternative_pulse_pressue_pp_d)

alternative_t_s = 0:1/fs:(sistolic_end-1)/fs;
alternative_t_d = sistolic_end/fs:1/fs:(length(Pao)-1)/fs;
% método alternativo propuesto por nosotros
alternative_pp_p_sis = (p_diastolic_end - r*q_max)*exp(-alternative_t_s/(alternative_pulse_pressure_compliance*r)) + r*q_max;
a = alternative_pp_p_sis(end);
alternative_pp_p_dia = a*exp(-(alternative_t_d - alternative_t_d(1))/(alternative_pulse_pressure_compliance*r));
alternative_pp_calculated_pressure = [alternative_pp_p_sis alternative_pp_p_dia];
figure
plot([t_s t_d], pp_calculated_pressure); hold on;
plot([t_s t_d], dt_calculated_pressure); hold on;
plot([t_s t_d], modified_pp_calculated_pressure); hold on;
plot([t_s t_d], alternative_pp_calculated_pressure); hold on;
plot(0:1/fs:(length(Pao)-1)/fs, Pao,'r');
text(diastolic_start/fs, pp_calculated_pressure(diastolic_start),'\leftarrow PPM')
text(diastolic_start/fs, dt_calculated_pressure(diastolic_start),'\leftarrow DTM')
text(location_p_max/fs, modified_pp_calculated_pressure(location_p_max),'\leftarrow MPPM')
text(sistolic_end/fs, alternative_pp_calculated_pressure(sistolic_end),'\leftarrow APPM')
title([titulo '\newlineComparación entre los métodos del paper y las alternativas propuestas'])
xlabel('t(s)')
ylabel('Presión (mmHg)')

end

