module my_riscv (
    input clk,          // Reloj del procesador
    input rst,          // Reset del procesador
    input [31:0] instr,  // Instrucción de entrada
    output [31:0] iaddr,

    output [31:0] daddr,
    input [31:0] ddata_in,
    output [31:0] ddata_out,
    output dwr_en,
    output drd_en
);

    // Contador de programa
    reg [31:0] pc;
    assign iaddr = pc;  // Conecta el PC al bus de direcciones de la IMEM
    wire [31:0] next_pc;
        

    // Contador en anillo que lleva el registro del estado dentro del ciclo de ejecución
    reg state_fetch, state_decode, state_execute;
    
    always @(negedge clk) begin
        if (rst) begin
            state_fetch <= 1;
            state_decode <= 0;
            state_execute <= 0;
        end else begin
            state_fetch <= state_execute;
            state_decode <= state_fetch;
            state_execute <= state_decode;
        end
    end

    reg [31:0] IR;      // Registro de instrucción
    
    // PC se inicializa en reset; la lógica de avance se agregará más adelante
    always @(posedge clk) begin
        if (rst)
            pc <= 32'h0;
        else if (state_execute)
            pc <= next_pc;
    end

    always @(posedge clk) begin
        if (rst)
            IR <= 32'd0;
        else if (state_fetch)
            IR <= instr;
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

    // señales de salto condicional individuales
    wire is_beq, is_bne, is_blt, is_bge, is_bltu, is_bgeu;
    wire is_auipc, is_lui; // para instrucciones tipo U
   
  register_file rv_rf (
    .clk(clk),
    // solo habilitamos escritura durante el ciclo de ejecución
    .wr_en(wr_en & state_execute),
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

    // --- comparador para saltos condicionales ---
    // usamos valores firmados para blt/bge, sin signo para bltu/bgeu
    wire signed [31:0] s1 = src1_value;
    wire signed [31:0] s2 = src2_value;
    wire taken_br;

    assign taken_br = (is_beq  && (src1_value == src2_value)) |
                      (is_bne  && (src1_value != src2_value)) |
                      (is_blt  && (s1 < s2)) |
                      (is_bge  && (s1 >= s2)) |
                      (is_bltu && (src1_value < src2_value)) |
                      (is_bgeu && (src1_value >= src2_value));

    // cálculo de valores para siguiente PC
    wire [31:0] pc_plus_4  = pc + 32'd4;
    wire [31:0] br_tgt_pc  = pc + imm;        // PC relativo + immediate
    assign next_pc    = (is_j_instr || taken_br) ? br_tgt_pc : pc_plus_4;

    // --- MUX para la entrada B de la ALU ---
    assign alu_a = is_auipc ? pc : is_lui ? 32'b0: (is_r_instr || is_i_instr) ? src1_value : 32'b0;
    // Aquí ya se implemento la figura 14 del documento de la guía
    assign alu_b = imm_valid ? imm : src2_value; // Si no es tipo R, usa el inmediato

    // --- Instanciación de la ALU ---
    alu_riscv rv_alu (
        .a(alu_a),
        .b(alu_b),
        .out(alu_out),
        // Aquí unimos las señales de tipo R con sus versiones inmediatas (tipo I)
        .ctrl({
            is_add | is_addi, is_lui | is_auipc, 
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

    // actualización del PC en etapa execute
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h0;
        end else if (state_execute) begin
            pc <= next_pc;
        end
    end

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

    // señales para cada tipo de rama (usar funct3)
    assign is_beq  = is_b_instr && (funct3 == 3'b000);
    assign is_bne  = is_b_instr && (funct3 == 3'b001);
    assign is_blt  = is_b_instr && (funct3 == 3'b100);
    assign is_bge  = is_b_instr && (funct3 == 3'b101);
    assign is_bltu = is_b_instr && (funct3 == 3'b110);
    assign is_bgeu = is_b_instr && (funct3 == 3'b111);

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

    // Señales tipo U
    assign is_auipc = is_u_instr && (opcode[6:2] == 5'b00101);
    assign is_lui   = is_u_instr && (opcode[6:2] == 5'b01101);

endmodule