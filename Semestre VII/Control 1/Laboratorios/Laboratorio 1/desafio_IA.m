% Definición del sistema y obtención de datos
[y, t] = step(tf(10, [1 3 10]));
% Graficar base
plot(t, y, 'Color', [1 0.7 0.2]); hold on;

indices = find(y > 1);

corte = find(diff(indices) > 1, 1);
if isempty(corte), corte = length(indices); end

% Extraer y superponer el primer segmento detectado
primer_bloque = indices(1:corte);
plot(t(primer_bloque), y(primer_bloque), 'r', 'LineWidth', 2);

grid on; title('Solución Optimizada');