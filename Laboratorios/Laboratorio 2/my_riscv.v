module my_riscv (
    input clk,          // Reloj del procesador
    input rst,          // Reset del procesador
    input [31:0] instr  // Instrucción de entrada
);

    reg [31:0] IR;      // Registro de instrucción

    always @(posedge clk) begin
        if (rst) IR <= 32'b0;
        else     IR <= instr;
    end

    // --- Extracción de los campos del registro de instrucción (IR) ---
    wire [6:0] funct7;
    wire [4:0] rs2;
    wire [4:0] rs1;
    wire [2:0] funct3;
    wire [4:0] rd;
    wire [6:0] opcode;

    assign funct7 = IR[31:25];
    assign rs2    = IR[24:20];
    assign rs1    = IR[19:15];
    assign funct3 = IR[14:12];
    assign rd     = IR[11:7];
    assign opcode = IR[6:0];

    // --- Salidas del Register File (RF) ---
    wire [31:0] src1_value;
    wire [31:0] src2_value;

    // --- Operandos de entrada a la ALU ---
    wire [31:0] alu_a;
    wire [31:0] alu_b;

    // --- Salida de la ALU ---
    wire [31:0] alu_out;

    // --- Señales de control de la unidad de control (CU) ---
    wire wr_en;
    wire [10:0] dec_bits;
    wire is_add, is_sub, is_sll, is_slt, is_sltu, is_xor, is_srl, is_sra, is_or, is_and;

    // Nuevas señales para tipos de instrucción
    wire is_r_instr;
    wire is_i_instr;
    wire is_s_instr;
    wire is_b_instr;
    wire is_u_instr;
    wire is_j_instr;
    wire is_valid; //---------------------------------------------------------------------

    // --- Instanciación del Register File (RF) ---
  register_file rv_rf (
    .clk(clk),
    .wr_en(wr_en),
    .wr_index(rd),
    .wr_data(alu_out),
    .rd_index1(rs1),
    .rd_data1(src1_value),
    .rd_index2(rs2),
    .rd_data2(src2_value)
 );

    // --- Generación del valor Inmediato (IMM) y extensión de signo ---
    // 
    wire [31:0] imm;
    assign imm = is_i_instr ? { {21{IR[31]}}, IR[30:20] } :
                 is_s_instr ? { {21{IR[31]}}, IR[30:25], IR[11:7] } :
                 is_b_instr ? { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0 } :
                 is_u_instr ? { IR[31:12], 12'b0 } :
                 is_j_instr ? { {12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0 } :
                 32'b0;

    wire imm_valid = is_i_instr | is_s_instr | is_b_instr | is_u_instr | is_j_instr;

    // --- MUX para la entrada B de la ALU ---
    assign alu_a = src1_value;
    assign alu_b = (is_r_instr) ? src2_value : imm; // Si no es tipo R, usa el inmediato

    // --- Instanciación de la ALU ---
    alu_riscv rv_alu (
        .a(alu_a),
        .b(alu_b),
        .out(alu_out),
        // Aquí unimos las señales de tipo R con sus versiones inmediatas (tipo I)
        .ctrl({
            is_add | is_addi, 
            is_sub, 
            is_sll | is_slli, 
            is_slt | is_slti, 
            is_sltu| is_sltui, 
            is_xor | is_xori, 
            is_srl | is_srli, 
            is_sra | is_srai, 
            is_or  | is_ori, 
            is_and | is_andi
        })
    );

    // --- Unidad de Control (CU) ---
    assign is_valid = (opcode[1:0] == 2'b11);
    
    // Identificación de Tipos
    assign is_r_instr = (opcode[6:2] == 5'b01100);
    assign is_i_instr = (opcode[6:2] == 5'b00000) || (opcode[6:2] == 5'b00100) || (opcode[6:2] == 5'b11001);
    assign is_s_instr = (opcode[6:2] == 5'b01000);
    assign is_b_instr = (opcode[6:2] == 5'b11000);
    assign is_u_instr = (opcode[6:2] == 5'b00101) || (opcode[6:2] == 5'b01101);
    assign is_j_instr = (opcode[6:2] == 5'b11011);

    assign wr_en = (is_r_instr | is_i_instr | is_u_instr | is_j_instr) & is_valid;

    // Decodificación de instrucciones Tipo R
    assign dec_bits = {funct7[5], funct3, opcode};
    assign is_add  = (dec_bits == 11'b0_000_0110011);
    assign is_sub  = (dec_bits == 11'b1_000_0110011);
    assign is_sll  = (dec_bits == 11'b0_001_0110011);
    assign is_slt  = (dec_bits == 11'b0_010_0110011);
    assign is_sltu = (dec_bits == 11'b0_011_0110011);
    assign is_xor  = (dec_bits == 11'b0_100_0110011);
    assign is_srl  = (dec_bits == 11'b0_101_0110011);
    assign is_sra  = (dec_bits == 11'b1_101_0110011);
    assign is_or   = (dec_bits == 11'b0_110_0110011);
    assign is_and  = (dec_bits == 11'b0_111_0110011);

    // Decodificación de instrucciones Tipo I (Opcodes inmediatos 00100)
    // Para las tipo I, funct7 no existe, solo usamos funct3 y opcode
    wire [9:0] dec_bits_i = {funct3, opcode};
    assign is_addi  = (dec_bits_i == 10'b000_0010011);
    assign is_slti  = (dec_bits_i == 10'b010_0010011);
    assign is_sltui = (dec_bits_i == 10'b011_0010011);
    assign is_xori  = (dec_bits_i == 10'b100_0010011);
    assign is_ori   = (dec_bits_i == 10'b110_0010011);
    assign is_andi  = (dec_bits_i == 10'b111_0010011);
    
    // Casos especiales de tipo I: desplazamientos (usan parte de funct7)
    assign is_slli  = (dec_bits == 11'b0_001_0010011);
    assign is_srli  = (dec_bits == 11'b0_101_0010011);
    assign is_srai  = (dec_bits == 11'b1_101_0010011);

endmodule