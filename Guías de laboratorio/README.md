# 🛠️ Guías de Laboratorio: Construcción de Microprocesador RISC-V

Aquí encontrarás el material y las guías de laboratorio correspondientes al diseño e implementación de un microcontrolador basado en la arquitectura RISC-V. 

El propósito principal de esta carpeta es hacer que la replicación de los experimentos sea lo más intuitiva y fluida posible. Para lograrlo, **he modificado las guías originales añadiendo comentarios detallados, correcciones matemáticas y explicaciones de código** basadas en la experiencia práctica de ensamblar el procesador paso a paso.

## 📌 ¿Qué encontrarás aquí?

* **Guías Documentadas:** Archivos con notas aclaratorias sobre conceptos de la arquitectura (ciclos de reloj adicionales para memoria sincrónica, diferencias entre instrucciones de salto `JAL`/`JALR`, y cálculos de direccionamiento efectivo).
* **Código Verilog Comentado:** Módulos de hardware (ALU, Unidad de Control, Memoria SRAM/ROM) con comentarios sobre la lógica implementada (como el manejo de alta impedancia `Hi-Z`) y la sintaxis correcta para evitar errores comunes de instanciación.
* **Programas de Prueba:** Códigos en ensamblador (`.s`) diseñados para estresar y validar instrucciones específicas, como las operaciones de carga y almacenamiento (`LOAD`/`STORE`).

## 🚀 Notas Clave para la Replicación

A lo largo de los archivos he documentado la solución a los problemas más frecuentes al momento de compilar y simular:
* **Cálculo de Direcciones:** Explicaciones sobre la alineación de memoria a 4 bytes y cómo recortar correctamente los buses de direcciones (ej. aislando los bits `[13:2]`).
* **Uso del Toolchain:** La secuencia exacta de comandos en terminal para compilar el ensamblador (`riscv64-unknown-elf-as`), convertirlo a binario crudo y utilizar scripts de Python (`makehex.py`) para generar los archivos `.hex` que inicializan las memorias en Verilog.
* **Simulación:** Instrucciones claras sobre cómo generar archivos `.vcd` y qué señales específicas rastrear en el diagrama de tiempos para verificar la máquina de estados.

## 💻 Herramientas Necesarias

Para ejecutar estos laboratorios correctamente, tu entorno de desarrollo debe contar con:
1.  **Icarus Verilog (`iverilog` / `vvp`):** Para compilar y simular la descripción de hardware.
2.  **GTKWave:** Para la visualización y análisis de las formas de onda.
3.  **RISC-V GNU Compiler Toolchain:** Para ensamblar los programas de prueba.
4.  **Python 3:** Para la conversión automática de archivos binarios a hexadecimales.

---
*Espero que estos comentarios y apuntes te ahorren horas de depuración y faciliten tu comprensión sobre el funcionamiento interno de la CPU.*
