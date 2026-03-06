% Definimos el sistema
num = [10];
den = [1 3 10];
H = tf(num, den);

% Obtenemos los datos numéricos de la respuesta al escalon 
[y, t] = step(H);

% graficamos la señal completa en color naranja
plot(t, y,'Color', [1 0.7 0.2]); 
hold on; 

% Buscamos el primer tramo que supera el valor unitario 1
% Usamos un ciclo para recorrer el vector de amplitud
inicio = 0;
fin = 0;

for i = 1:length(y)
    if y(i) > 1 && inicio == 0
        inicio = i; % Guardamos donde empieza a subir de 1
    end
    if y(i) < 1 && inicio ~= 0
        fin = i;    % Guardamos donde vuelve a bajar de 1
        break;      % Salimos del ciclo al encontrar el primer tramo
    end
end

% Si encontramos un tramo, extraemos esos puntos y los graficamos encima
if inicio ~= 0 && fin ~= 0
    y_tramo = y(inicio:fin);
    t_tramo = t(inicio:fin);
    plot(t_tramo, y_tramo, 'r', 'LineWidth', 2); % Graficamos en rojo
end

grid on;
title('Desafío de Lógica:');
hold off;