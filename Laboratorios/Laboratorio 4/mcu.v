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
    reg [31:0] mem [0:4095];

    // Lógica de lectura combinacional
    always @(*) begin
        data = mem[addr];
    end

    // Inicialización de la memoria usando archivo externo
    initial begin
        // La directiva $readmemh busca un archivo de texto con valores en hexadecimal
        // y los carga secuencialmente en el arreglo 'rom'
        $readmemh("test_program.hex", mem);//se tiene que llamar igual que el archivo que se va a cargar, en este caso programa.hex
        //guía 3 testbench , usar ese
    end

endmodule