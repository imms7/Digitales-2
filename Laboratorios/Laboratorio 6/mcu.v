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

    sram_4096x32 DMEM(
        .clk(clk),
        .addr(daddr[13:2]),  //Va de [13:2] (12 bits)
        .wr_en(dwr_en),
        .wr_data(ddata_out),
        .rd_en(drd_en),
        .rd_data(ddata_in)
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

module sram_4096x32 (
    input clk,
    input [11:0] addr,        // Dirección interna de 12 bits (para 4096 posiciones)
    input wr_en,              // Habilitación de escritura
    input [31:0] wr_data,     // Bus de datos de entrada (escritura)
    input rd_en,              // Habilitación de lectura
    output [31:0] rd_data     // Bus de datos de salida (lectura)
);

    // Declaración del arreglo de memoria: 4096 posiciones de 32 bits (palabras)
    reg [31:0] ram [0:4095];
    
    // Registro interno para almacenar el dato leído de forma sincrónica
    reg [31:0] data_out_reg;

    // Proceso sincrónico para escritura y lectura
    always @(posedge clk) begin
        // Si la escritura está habilitada, guarda el dato
        if (wr_en) begin
            ram[addr] <= wr_data;
        end
        
        // Lectura sincrónica al registro interno
        data_out_reg <= ram[addr];
    end

    // Lógica de Alta Impedancia (Hi-Z)
    // Cuando rd_en es 0, el bus se libera (pasa a Z) para evitar cortocircuitos
    assign rd_data = (rd_en) ? data_out_reg : 32'bz;
    
endmodule