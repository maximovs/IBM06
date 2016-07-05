%% Se importan archivos de datos.
% Se utiliza lafunción Import Data de Matlab.
[arm, mod_q,pha_q, mod_p,pha_p] = importfile('Workbook1.csv',2, 12);

%% Se calculan variables características.
z = abs(mod_p./mod_q);
z0 = mean(z(2:end));
fs = 250;
t = 0:1/fs:2-(1/fs);
q = to_time(mod_q, pha_q, t);
p = to_time(mod_p, pha_p, t);

%% Se calcula flujo y presión incidentes y reflejados.
% A partir de la impedancia y la presión y flujo en función del tiempo se
% calculan el flujo incidente y reflejado y la presión inciente y
% reflejada.
q_inc = (q + p/z0)/2;
q_ref = (q - p/z0)/2;

p_inc = (p + q*z0)/2;
p_ref = (p - q*z0)/2;
figure
plot(t, p); hold on;
plot(t, p_inc, '--'); hold on;
plot(t, p_ref, ':'); hold on;
figure
plot(t, q); hold on;
plot(t, q_inc, '--'); hold on;
plot(t, q_ref, ':'); hold on;

%% Obtener función transferencia a partir de presión central y periférica.

% [PeriphSignal,CentralSignal,pp_joven2,pc_joven2] = importfile_joven2('Senales_TP_FT/Jovenes 20-29/Joven2_20a29.txt',1, 1153);
% [PeriphSignal,CentralSignal,pp_joven1,pc_joven1] = importfile_joven1('Senales_TP_FT/Jovenes 20-29/Joven1_20a29.txt',1, 1153);
% [PeriphSignal,CentralSignal,pp_hta2,pc_hta2] = importfile_hta2('Senales_TP_FT/Hpertensos 50-59/HTA2_50a59.txt',1, 1153);
% [PeriphSignal,CentralSignal,pp_hta1,pc_hta1] = importfile_hta1('Senales_TP_FT/Hpertensos 50-59/HTA1_50a59.txt',1, 1153);
% [PeriphSignal,CentralSignal,pp_adulto2,pc_adulto2] = importfile_adulto2('Senales_TP_FT/Adultos 60-69/Adulto2_60a69.txt',1, 1153);
[pp_adulto1,pc_adulto1] = importfile_adulto1('Senales_TP_FT/Adultos 60-69/Adulto1_60a69.txt',2, 129);
[pp_joven1,pc_joven1] = importfile_joven1('Senales_TP_FT/Jovenes 20-29/Joven1_20a29.txt',2, 104);
[pp_adulto2,pc_adulto2] = importfile_adulto2('Senales_TP_FT/Adultos 60-69/Adulto2_60a69.txt',2, 136);
[pp_hta1,pc_hta1] = importfile_hta1('Senales_TP_FT/Hpertensos 50-59/HTA1_50a59.txt',2, 125);
[pp_hta2,pc_hta2] = importfile_hta2('Senales_TP_FT/Hpertensos 50-59/HTA2_50a59.txt',2, 114);
[pp_joven2,pc_joven2] = importfile_joven2('Senales_TP_FT/Jovenes 20-29/Joven2_20a29.txt',2, 83);

size = min([length(pp_adulto1), length(pp_adulto2), length(pp_joven1), length(pp_joven2), length(pp_hta1), length(pp_hta2)]);

figure
subplot(3,2,1)
pp = pp_adulto1;
pc = pc_adulto1;
t = 0:1/fs:(length(pc)-1)/fs;
plot(t', pp); hold on;
plot(t', pc);
subplot(3,2,2)
pp = pp_adulto2;
pc = pc_adulto2;
t = 0:1/fs:(length(pc)-1)/fs;
plot(t', pp); hold on;
plot(t', pc);
subplot(3,2,3)
pp = pp_joven1;
pc = pc_joven1;
t = 0:1/fs:(length(pc)-1)/fs;
plot(t', pp); hold on;
plot(t', pc);
subplot(3,2,4)
pp = pp_joven2;
pc = pc_joven2;
t = 0:1/fs:(length(pc)-1)/fs;
plot(t', pp); hold on;
plot(t', pc);
subplot(3,2,5)
pp = pp_hta1;
pc = pc_hta1;
t = 0:1/fs:(length(pc)-1)/fs;
plot(t', pp); hold on;
plot(t', pc);
subplot(3,2,6)
pp = pp_hta2;
pc = pc_hta2;
t = 0:1/fs:(length(pc)-1)/fs;
plot(t', pp); hold on;
plot(t', pc);


[~, H_joven_1] = get_transference(pp_joven1(1:size), pc_joven1(1:size), size);
[~, H_joven_2] = get_transference(pp_joven2(1:size), pc_joven2(1:size), size);
figure
plot(abs(H_joven_1)); hold on;
plot(abs(H_joven_2));


PP_1 = fft(pp_joven1(1:size), size);
PP_H_1 = PP_1.*H_joven_1;
pc_calculada_1 = ifft(PP_H_1);

PP_2 = fft(pp_joven2(1:size), size);
PP_H_2 = PP_2.*H_joven_1;
pc_calculada_2 = ifft(PP_H_2);

figure
subplot(4,1,1)
plot(pc_calculada_1);
subplot(4,1,2)
plot(pc_joven1);
subplot(4,1,3)
plot(pc_calculada_2);
subplot(4,1,4)
plot(pc_joven2);

PP_1 = fft(pp_joven1(1:size), size);
PP_H_1 = PP_1.*H_joven_2;
pc_calculada_1 = ifft(PP_H_1);

PP_2 = fft(pp_joven2(1:size), size);
PP_H_2 = PP_2.*H_joven_2;
pc_calculada_2 = ifft(PP_H_2);

figure
subplot(2,1,1)
plot(pc_calculada_1); hold on;
plot(pc_joven1(1:size));
subplot(2,1,2)
plot(pc_calculada_2); hold on;
plot(pc_joven2(1:size));
