module mcu( input clk, //Reloj del microcontrolador
            input rst //Reset del microcontrolador
            );
    
    //Buses con la memoria de programa (IMEM)
    wire [31:0] instr; //Instrucción de entrada
    wire [31:0] iaddr; //Dirección en la IMEM
    
    //Buses con la memoria de datos (DMEM)
    wire [31:0] daddr; //Dirección en la DMEM
    wire [31:0] ddata_in; //Bus de datos DMEM (entrada)
    wire [31:0] ddata_out; //Bus de datos DMEM (salida)
    wire dwr_en; //Señales del bus de control DMEM
    wire drd_en; //
    
    // Instancia del microprocesador RISCV
    my_riscv cpu (
        .rst(rst),
        .clk(clk),
        .instr(instr),
        .iaddr(iaddr),
        .daddr(daddr),
        .ddata_in(ddata_in),
        .ddata_out(ddata_out),
        .dwr_en(dwr_en),
        .drd_en(drd_en)
    );
    
    // Instancia de la memoria de programa
    rom4096x32 IMEM(
        .data(instr),
        .addr(iaddr[13:2])
    );

endmodule

//Pon aquí la declaración de la memoria ROM de programa

// --- Declaración de la memoria ROM de programa ---
module rom4096x32 (
    input wire [11:0] addr,  // Dirección (4096 palabras -> 12 bits)
    output reg [31:0] data   // Datos de 32 bits
);

    // Definición del arreglo de memoria (4096 localidades de 32 bits)
    reg [31:0] rom [4095:0];

    // Lógica de lectura combinacional
    always @(*) begin
        data = rom[addr]; //switch case , inicializame esta rom , o readme , hay dos formas de hacer la memoria rom
    end

    // Inicialización de la memoria con instrucciones de prueba
    initial begin
        // Programa del ejemplo "while" de la guía (sin SW/LW)
        // x3 = 0; x5 = 0; x6 = 5; while (x5 < x6) { x3 += x5; x5++; } x12 = x3;
        rom[0]  = 32'h000001b3;  // add   x3, x0, x0
        rom[1]  = 32'h000002b3;  // add   x5, x0, x0
        rom[2]  = 32'h00500313;  // addi  x6, x0, 5
        rom[3]  = 32'h62d863;    // bge   x5, x6, finwhile (offset +16)
        rom[4]  = 32'h5181b3;    // add   x3, x3, x5
        rom[5]  = 32'h128293;    // addi  x5, x5, 1
        rom[6]  = 32'hff5ff06f;  // jal   x0, while1 (offset -12)
        rom[7]  = 32'h018633;    // add   x12, x3, x0  (finwhile)
        // resto de la ROM queda en cero (por default)
    end

endmodule