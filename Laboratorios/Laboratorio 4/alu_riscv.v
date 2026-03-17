module alu_riscv (
    
    input [31:0] a, b,
    input [9:0] ctrl, // Vector de 10 bits: {add, sub, sll, slt, sltu, xor, srl, sra, or, and}
    output reg [31:0] out
);
    wire [4:0] shamt;
    wire [63:0] a_ext;
    wire [31:0] sltu_result;
    wire [31:0] slt_result;
    
    //Valor del shift 
    assign shamt = b[4:0]; 
    //Extensión de signo de la entrada a para 64bits 
    assign a_ext = { {32{a[31]}}, a }; //Valor obtenido por set if less than unsigned (sltu) 
    assign sltu_result = {31'b0, a < b}; //Valor obtenido por set if less than (signed) 
    assign slt_result = (a[31]==b[31]) ? sltu_result : {31'b0, a[31]};
    
    always @(*) begin
     // 
        case (ctrl)
            10'b1000000000: out = a + b;         // add
            10'b0100000000: out = a - b;         // sub
            10'b0010000000: out = a << shamt;   // sll
            10'b0001000000: out = slt_result; // slt
            10'b0000100000: out = sltu_result; // sltu
            10'b0000010000: out = a ^ b;         // xor
            10'b0000001000: out = a >> shamt;   // srl
            10'b0000000100: out = a_ext >> shamt;// SRA , Cambiar este triple >>> , no es compatible, mejor tomar una extension de signo de 64 bits y tomar los bits necesarios dependiendo el valor de corriemiento, según el 
            10'b0000000010: out = a | b;         // or
            10'b0000000001: out = a & b;         // and

      /*      10'b1000000000: ALU_out = a + b; // SUMA
            10'b0100000000: ALU_out = a - b; // RESTA
            10'b0010000000: ALU_out = a & b; // AND
            10'b0001000000: ALU_out = a | b; // OR
            10'b0000100000: ALU_out = a ^ b; // XOR
            10'b0000010000: ALU_out = a << shamt;      // SLL
            10'b0000001000: ALU_out = a >> shamt;      // SRL
            10'b0000000100: ALU_out = a_ext >> shamt;  // SRA
            10'b0000000010: ALU_out = slt_result;      // SLT
            10'b0000000001: ALU_out = sltu_result;     // SLTU */

        /*  10'b1000000000: out = a + b;         // add
            10'b0100000000: out = a - b;         // sub
            10'b0010000000: out = a << b[4:0];   // sll
            10'b0001000000: out = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // slt
            10'b0000100000: out = (a < b) ? 32'b1 : 32'b0; // sltu
            10'b0000010000: out = a ^ b;         // xor
            10'b0000001000: out = a >> b[4:0];   // srl
            10'b0000000100: out = $signed(a) >>> b[4:0]; // SRA , Cambiar este triple >>> , no es compatible, mejor tomar una extension de signo de 64 bits y tomar los bits necesarios dependiendo el valor de corriemiento, según el 
            10'b0000000010: out = a | b;         // or
            10'b0000000001: out = a & b;         // and  */
            default:        out = 32'b0;
        endcase
    end
endmodule