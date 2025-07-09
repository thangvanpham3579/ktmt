module RISCV_Single_Cycle(
    // Clock signal
    input logic clk,
    // Active-low reset signal
    input logic rst_n,
    // Current PC output for external observation (e.g., testbench)
    output logic [31:0] PC_out_top,
    // Instruction fetched from instruction memory
    output logic [31:0] Instruction_out_top
);


    logic [31:0] PC_next;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] opcode, funct7;
    logic [31:0] Imm;
    logic [31:0] ReadData1, ReadData2, WriteData;
    logic [31:0] ALU_in2, ALU_result;
    logic ALUZero;
    logic [31:0] MemReadData;
    logic [1:0] ALUSrc;       // Selects ALU second operand
    logic [3:0] ALUCtrl;      // ALU operation selector
    logic Branch;             // Branch control signal
    logic MemRead;            // Enable reading from data memory
    logic MemWrite;           // Enable writing to data memory
    logic MemToReg;           // Selects data for register write-back
    logic RegWrite;           // Enable writing to register file
    logic PCSel;              // Selects next PC: sequential or branch

    // Program Counter update: synchronous with clk, asynchronous reset
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC_out_top <= 32'b0;    // Reset PC to 0
        else
            PC_out_top <= PC_next;  // Update PC with next value
    end


    instmem IMEM_inst(
        .addr(PC_out_top),
        .Instruction(Instruction_out_top)
    );

    // Instruction decoding: split instruction fields for control and datapath
    assign opcode = Instruction_out_top[6:0];
    assign rd     = Instruction_out_top[11:7];
    assign funct3 = Instruction_out_top[14:12];
    assign rs1    = Instruction_out_top[19:15];
    assign rs2    = Instruction_out_top[24:20];
    assign funct7 = Instruction_out_top[31:25];


    immgen imm_gen(
        .inst(Instruction_out_top),
        .imm_out(Imm)
    );
    regfile Reg_inst(
        .clk(clk),
        .rst_n(rst_n),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );
    assign ALU_in2 = (ALUSrc[0]) ? Imm : ReadData2;
    alu alu(
        .A(ReadData1),
        .B(ALU_in2),
        .ALUOp(ALUCtrl),
        .Result(ALU_result),
        .Zero(ALUZero)
    );
    datamem DMEM_inst(
        .clk(clk),
        .rst_n(rst_n),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(ALU_result),
        .WriteData(ReadData2),
        .ReadData(MemReadData)
    );
    assign WriteData = (MemToReg) ? MemReadData : ALU_result;
    controlunit ctrl(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUCtrl),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite)
    );
    branchunit comp(
        .A(ReadData1),
        .B(ReadData2),
        .Branch(Branch),
        .funct3(funct3),
        .BrTaken(PCSel)
    );

    // Next PC logic: PC+4 for sequential execution or PC+Imm for branch
    assign PC_next = (PCSel) ? PC_out_top + Imm : PC_out_top + 4;

endmodule
