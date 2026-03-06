% Script de MATLAB para graficar respuestas temporales escaladas
clear; clc; close all;

%% 1. Definición de las Funciones de Transferencia (TF)
% Definimos el operador de Laplace s
s = tf('s');

% --- Sistema Mecánico ---
R = 470;
L = 4.7e-3;
C = 10e-9;
H_mecanico = 1 / (L*C*s^2 + R*C*s + 1);
H_mecanico.Name = 'Sistema (TF\_RLC)';

% --- Sistema Rediseñado ---
m_red = 0.5;
b_red = 3.5;
k_red = 50;
H_redisenado = 1 / (m_red*s^2 + b_red*s + k_red);
H_redisenado.Name = 'Sistema Rediseñado (TF\_ Mecanica Rediseñada)';

%% 2. Extracción Automática de Características (Pico y Tiempo de Establecimiento)
% Usamos stepinfo para obtener los datos de la respuesta al escalón

% Info del Sistema Mecánico
info_mec = stepinfo(H_mecanico);
Ts_mec = info_mec.SettlingTime;
Peak_mec = info_mec.Peak;

% Info del Sistema Rediseñado
info_red = stepinfo(H_redisenado);
Ts_red = info_red.SettlingTime;
Peak_red = info_red.Peak;

%% 3. Generación de las Respuestas al Escalón con Rangos Calculados
% Según el requerimiento: Eje X hasta 2*Ts.
t_final_mec = 2 * Ts_mec;
t_final_red = 2 * Ts_red;

% Obtenemos las curvas de respuesta para los tiempos definidos
[y_mec, t_mec] = step(H_mecanico, t_final_mec);
[y_red, t_red] = step(H_redisenado, t_final_red);

%% 4. Graficación con Escalas Específicas
figure('Name', 'Comparación de Respuestas Temporales Escaladas', 'Color', 'w', 'Position', [100 100 1000 700]);

% --- Subplot 1: Sistema Mecánico ---
subplot(2,1,1);
plot(t_mec, y_mec, 'b', 'LineWidth', 1.5);
grid on;

% Configuración de los ejes solicitada
% X de 0 a 2*Ts. Y de 0 al valor pico.
xlim([0 t_final_mec]);
ylim([0 Peak_mec * 1.05]); % Se añade un 5% de margen superior para visualización

% Etiquetas y Títulos
title(['Respuesta al Escalón: ' H_mecanico.Name], 'FontSize', 12);
ylabel('Amplitud', 'FontSize', 11);
xlabel('Tiempo (segundos)', 'FontSize', 11);

% Añadir anotaciones de los valores calculados
text(t_final_mec*0.6, Peak_mec*0.3, ...
    sprintf('Ts = %.2e s\nPico = %.2f', Ts_mec, Peak_mec), ...
    'BackgroundColor', 'w', 'EdgeColor', 'k');

% --- Subplot 2: Sistema Rediseñado ---
subplot(2,1,2);
plot(t_red, y_red, 'r', 'LineWidth', 1.5);
grid on;

% Configuración de los ejes solicitada
% X de 0 a 2*Ts. Y de 0 al valor pico.
xlim([0 t_final_red]);
ylim([0 Peak_red * 1.05]); % Se añade un 5% de margen superior

% Etiquetas y Títulos
title(['Respuesta al Escalón: ' H_redisenado.Name], 'FontSize', 12);
ylabel('Amplitud', 'FontSize', 11);
xlabel('Tiempo (segundos)', 'FontSize', 11);

% Añadir anotaciones de los valores calculados
text(t_final_red*0.6, Peak_red*0.3, ...
    sprintf('Ts = %.2f s\nPico = %.2e', Ts_red, Peak_red), ...
    'BackgroundColor', 'w', 'EdgeColor', 'k');

% Mejora de la disposición
sgtitle('Validación de Equivalencia Dinámica mediante Escalamiento', 'FontSize', 14, 'FontWeight', 'bold');