 % Sistema Mecánico Realizable
m = 0.5;   % Masa en kg
k = 50;    % Constante del resorte en N/m
b = 3.5;   % Coeficiente de amortiguamiento (calculado)

% Definición de la Función de Transferencia H(s) = 1 / (ms^2 + bs + k)
sys_mecanico = tf([1], [m, b, k]);

% Al graficar, verás que el sobreimpulso es exactamente el esperado
step(sys_mecanico);
title('Respuesta del Sistema Mecánico Realizable');
grid on;

% Validación de parámetros en la consola
damp(sys_mecanico)