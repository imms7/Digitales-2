`timescale 1ns/1ps

module tb_riscv;
  
  // Señales de prueba
  reg  [31:0] instr;
  reg  clk;
  reg  rst;
  
  
  // Instancia del DUT (Device Under Test)
  my_riscv uut (
    .clk(clk),
    .rst(rst),
    .instr(instr)
  );

  // Bloque inicial: aplica estímulos
  integer i;
  initial begin

    // Configurar la generación de archivos de volcado
    $dumpfile("tb_riscv.vcd");
    $dumpvars(0, tb_riscv);
	for(i=0; i<32; i=i+1) $dumpvars(0, uut.rv_rf.mem[i]);
    
    //Inicia el register file para facilitar la prueba
	//En este caso cada registro xN toma el valor de N, por ejemplo, x10 = 10.
    for(i=0; i<32; i=i+1) uut.rv_rf.mem[i] = i;
    
    // Muestra en consola los valores de interés cada vez que cambien
    $monitor($time, " clk=%d | ins=%h x4=%h x5=%h x6=%h", clk, instr, uut.rv_rf.mem[4], uut.rv_rf.mem[5], uut.rv_rf.mem[6]);

    #0;  clk = 0;
		 rst = 1;
	
    #3;  rst = 0; 
    	 instr = 32'b0000000_00010_00011_000_00100_0110011;  //add x4, x3, x2
    	 $display("add x4, x3, x2");
    
    #8;  instr = 32'b0100000_00010_00011_000_00101_0110011;  //sub x5, x3, x2 
    	 $display("sub x5, x3, x2");
    
    #8;  instr = 32'b0000000_01100_01010_111_00110_0110011;  //and x6, x10, x12  
    	 $display("and x6, x10, x12");

	#8;
    // Fin de la simulación -----------------------
    
    // --- Prueba de Instrucciones Tipo I ---
    
    // 1. addi x4, x3, 10  -> x4 = x3 + 10. Como x3=3, x4 debería ser 13 (0xd)
    instr = 32'h00a18213; 
    #8; // Esperar un ciclo de reloj

    // 2. xori x5, x4, 15  -> x5 = x4 ^ 15.
    instr = 32'h00f24293; 
    #8;

    // 3. andi x6, x1, 1   -> x6 = x1 & 1. Como x1=1, x6 debería ser 1.
    instr = 32'h0010f313;
    #16;//-----------------------------------------
    $finish;
  end
  
  always
    begin
        #2 clk=!clk;
    end

endmodule