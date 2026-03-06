MONTAJEF = readmatrix('ciclo1.CSV','NumHeaderLines', 1);
L = 4.7e-3;      % 4.7 mH
C = 10e-9;       % 10 nF (Nuevo valor)
R = 470;         % 470 Ohms (Valor comercial)

% Se  procede a graficar la entrada física
tiempo = MONTAJEF(:,1);
entrada = MONTAJEF(:,2);
figure;
plot(tiempo, entrada, 'b','LineWidth',1);
grid on
xlabel('Tiempo (s)')
ylabel('Amplitud (V)')
title('Entrada física medida') 

tiempo = tiempo - tiempo(1);   % que arranque en 0
% Crear objeto timeseries para Simulink
entradaexp = timeseries(entrada, tiempo);