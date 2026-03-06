L = 4.7e-3;      
C = 10e-9;       
R = 470;         
num = [1];
den = [L*C R*C 1];
H = tf(num, den);

% --- Nueva sección: Simulación con lsim ---

% 1. Definir el vector de tiempo (0 a 1 ms con pasos de 2 microsegundos)
t = 0:1e-6:1e-3; 

% 2. Crear la entrada senoidal (Frecuencia de  kHz)
f = 23000; 
u = sin(2*pi*f*t);
% 3. Simular la respuesta del sistema
[y, t_out] = lsim(H, u, t);

% 4. Graficar Resultados
figure;
plot(t, u, 'r--', 'LineWidth', 1.5); hold on;
plot(t_out, y, 'b', 'LineWidth', 1.5);
grid on;
title('Respuesta del Sistema H(s) ante Entrada Senoidal');
xlabel('Tiempo (s)');
ylabel('Amplitud');
legend('Entrada u(t)', 'Respuesta y(t)');