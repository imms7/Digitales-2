`timescale 1ns/1ps

// Test bench para mcu (verifica ALU: sll, srl, sra, slt, sltu y otras)
module tb_mcu;
  
  // Señales de prueba
  reg  clk;
  reg  rst;
  
  // Instancia del microcontrolador
  mcu mcuuq (
    .rst(rst),
    .clk(clk)
  );

  integer i;
  // Bloque inicial: aplica estímulos
  initial begin
    // Configurar la generación de archivos de volcado
    $dumpfile("FINAL_GREAT.vcd");
    $dumpvars(0, tb_mcu);
	for(i=0; i<32; i=i+1) $dumpvars(0, mcuuq.cpu.rv_rf.mem[i]);
    
    // Inicializar señales
    #0;  clk = 0;
		 rst = 1;
	
    #5;  rst = 0;

    // Dejar ejecutar el programa suficiente tiempo (ajusta si tu CPU es lenta)
    #1000;

    $display("========================================");
    $display("RESULTADOS DEL TEST RV32I - COMPROBACION ALU");
    $display("========================================");

    check_reg(4 , 32'd64);        // SLL
    check_reg(5 , 32'd1);         // SRL
    check_reg(6 , 32'hFFFFFFFF);  // SRA (-1)
    check_reg(7 , 32'd11);        // ADD
    check_reg(8 , 32'd5);         // SUB
    check_reg(9 , 32'd0);         // AND
    check_reg(10, 32'd11);        // OR
    check_reg(11, 32'd11);        // XOR
    check_reg(12, 32'd1);         // SLT
    check_reg(13, 32'd0);         // SLTU

    $display("========================================");
    $finish;
  end

  // Reloj
  always begin
    #2 clk = !clk; // periodo 4ns (250 MHz simulado)
  end

// ==================================================
// TASK PARA VERIFICAR REGISTROS
// ==================================================
task check_reg;
    input [4:0] reg_index;
    input [31:0] expected;

    reg [31:0] value;

    begin
        // Acceso jerárquico al array interno regs del register_file
        value = mcuuq.cpu.rv_rf.mem[reg_index];

        if (value === expected)
            $display("OK   x%0d = 0x%08h", reg_index, value);
        else
            $display("FAIL x%0d = 0x%08h (esperado 0x%08h)", reg_index, value, expected);
    end
endtask

endmodule