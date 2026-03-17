# Programa de prueba completo - RV32I
# Incluye: Tipo R, Tipo I, Tipo U (LUI, AUIPC)
.section .text
.globl _start

_start:
    # --- 1. Inicialización de registros base ---
    addi x1, x0, 15      # x1 = 15
    addi x2, x0, 10      # x2 = 10

    # --- 2. Pruebas Tipo I (Inmediatos) ---
    addi x3, x1, 5       # x3 = 15 + 5 = 20 (0x14)
    andi x4, x1, 7       # x4 = 15 & 7 = 7
    ori  x5, x2, 4       # x5 = 10 | 4 = 14 (0x0E)
    xori x6, x1, 15      # x6 = 15 ^ 15 = 0

    # --- 3. Pruebas Tipo R (Registro-Registro) ---
    # Usamos los valores de x1 (15) y x2 (10)
    add  x7,  x1, x2     # x7 = 15 + 10 = 25 (0x19)
    sub  x8,  x1, x2     # x8 = 15 - 10 = 5  (0x05)
    sll  x9,  x1, x2     # x9 = 15 << 10 (desplazamiento por registro)
    slt  x10, x1, x2     # x10 = (15 < 10) ? 1 : 0 -> 0
    sltu x11, x1, x2     # x11 = (15 < 10) unsigned -> 0
    xor  x12, x1, x2     # x12 = 15 ^ 10 = 5
    srl  x13, x1, x2     # x13 = 15 >> 10 (lógico)
    sra  x14, x1, x2     # x14 = 15 >> 10 (aritmético)
    or   x15, x1, x2     # x15 = 15 | 10 = 15 (0x0F)
    and  x16, x1, x2     # x16 = 15 & 10 = 10 (0x0A)

    # --- 4. Pruebas de Desplazamiento Inmediato ---
    slli x17, x1, 2      # x17 = 15 << 2 = 60 (0x3C)
    
    addi x18, x0, -100   # x18 = -100
    srli x19, x18, 2     # x19 = -100 >> 2 (Lógico: número positivo grande)
    srai x20, x18, 2     # x20 = -100 >> 2 (Aritmético: -25 o 0xFFFFFFE7)

    # --- 5. Pruebas Tipo U (LUI y AUIPC) ---
    # LUI: Carga los 20 bits en la parte alta (bits 31:12)
    lui  x21, 0x12345    # x21 = 0x12345000
    
    # AUIPC: Suma el inmediato desplazado al PC actual
    # Si esta instrucción está en la dirección 0x50, x22 será 0x50 + 0x12345000
    auipc x22, 0x12345   

    # --- 6. Pruebas de Comparación Inmediata ---
    slti  x23, x1, 20    # x23 = (15 < 20) ? 1 : 0 -> 1
    sltiu x24, x1, 5     # x24 = (15 < 5) unsigned -> 0

    # Bucle infinito final
    loop: j loop
    