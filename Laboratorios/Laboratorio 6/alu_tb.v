`timescale 1ns / 1ps

module alu_tb;

    // 1. Declaración de señales para conectar con el módulo
    reg [31:0] a;
    reg [31:0] b;
    reg [1:0]  op;
    wire [31:0] alu_out;

    // 2. Instanciación de la ALU (Unit Under Test - UUT)
    alu_simple uut (
        .a(a),
        .b(b),
        .op(op),
        .alu_out(alu_out)
    );

    // 3. Generación de estímulos
    initial begin
        // Configuración para GTKWave: Crea el archivo de volcado de datos
        $dumpfile("alu_test.vcd"); 
        $dumpvars(0, alu_tb);

        // Monitor en consola para ver resultados rápidos
        $display("Tiempo | A | B | Op | Resultado");
        $monitor("%t | %d | %d | %b | %d", $time, a, b, op, alu_out);

        // Prueba 1: Suma (op = 00)
        a = 32'd100; b = 32'd50; op = 2'b00;
        #10; // Espera 10 unidades de tiempo

        // Prueba 2: Resta (op = 01)
        a = 32'd100; b = 32'd50; op = 2'b01;
        #10;

        // Prueba 3: AND (op = 10)
        a = 32'hAAAA_AAAA; b = 32'h5555_5555; op = 2'b10;
        #10;

        // Prueba 4: OR (op = 11)
        a = 32'hF0F0_F0F0; b = 32'h0F0F_0F0F; op = 2'b11;
        #10;

        // Prueba 5: Suma con cero
        a = 32'd0; b = 32'd25; op = 2'b00;
        #10;

        // Prueba 6: Resta con resultado negativo
        a = 32'd20; b = 32'd50; op = 2'b01;
        #10;
       
        // Prueba 7: AND con ceros
        a = 32'h0000_0000; b = 32'hFFFF_FFFF; op = 2'b10;
        #10;

        // Prueba 8: OR con ceros
        a = 32'h0000_0000; b = 32'h0000_0000; op = 2'b11;
        #10;

        $display("Simulación finalizada.");
        $finish;
    end

endmodule