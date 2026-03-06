% 1. Definir los coeficientes (Ejemplo: H(s) = 10 / (s^2 + 3s + 10))
num = [10];          % Numerador
den = [1 3 10];      % Denominador: s^2 + 3s + 10

% 2. Crear la función de transferencia
H = tf(num, den);

% División de la figura en una malla de 2x1 y selección del primer cuadrante.
subplot(2,1,1);
% Simulación y visualización de la respuesta temporal ante una entrada escalón.
step(H);
% Activación de la rejilla para facilitar la lectura de parámetros temporales.
grid on;
title('Respuesta al escalón');

% Selección del segundo cuadrante de la figura.
subplot(2,1,2);
% Simulación de la respuesta del sistema ante una excitación de tipo impulso.
impulse(H);
% Inclusión de rejilla para análisis de la respuesta transitoria.
grid on;
title('Respuesta al impulso');