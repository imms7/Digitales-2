% Parámetros actualizados
L = 4.7e-3;      % 4.7 mH
C = 10e-9;       % 10 nF (Nuevo valor)
R = 470;         % 470 Ohms (Valor comercial)

% Función de Transferencia
num = [1];
den = [L*C R*C 1];
H = tf(num, den);

% Gráfica y análisis
figure;
step(H);
grid on;
title('Diseño RLC: L=4.7mH, C=10nF, R=470\Omega');

% Mostrar resultados en consola
info = stepinfo(H);
fprintf('Sobreimpulso calculado: %.2f%%\n', info.Overshoot);
fprintf('Tiempo de asentamiento: %.2e s\n', info.SettlingTime);