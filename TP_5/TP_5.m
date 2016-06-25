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
