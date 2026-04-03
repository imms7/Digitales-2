`timescale 1ns/1ps //Test bench para el microcontrolador 
module tb_mcu; 
    // Señales de prueba 
    reg clk; 
    reg rst; 
    
    // Cables para observar los puertos
    wire [7:0] porta_out, portb_out;
    reg [7:0] portc_in;


    // Instancia del microcontrolador 
    mcu mcuuq ( 
        .clk(clk),
        .rst(rst), 
        .PORTA(porta_out),
        .PORTB(portb_out),
        .PORTC(portc_in)
    ); 
    
    integer i; 
    
    // Bloque inicial: aplica estímulos 
    initial begin 
        // Configurar la generación de archivos de volcado 
        $dumpfile("tb_mcu.vcd"); 
        $dumpvars(0, tb_mcu); 
        for(i=0; i<32; i=i+1) 
            $dumpvars(0, mcuuq.cpu.rv_rf.mem[i]); 
        #0; 
        clk = 0; 
        rst = 1; 
        #9; 
        rst = 0; 
        #550; //Termina después de 25 ciclos de reloj 
        #16; // Fin de la simulación 
        $finish; 
    end 
    
    always begin 
        #2 clk=!clk; 
    end 
endmodule