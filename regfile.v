module regfile(
    input logic clk,
    input logic RegWrite,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] WriteData,
    output logic [31:0] ReadData1,
    output logic [31:0] ReadData2,
    input logic rst_n  
);
    logic [31:0] registers [0:31];

    assign ReadData1 = (rs1 != 0) ? registers[rs1] : 32'b0;
    assign ReadData2 = (rs2 != 0) ? registers[rs2] : 32'b0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else if (RegWrite && rd != 0) begin
            registers[rd] <= WriteData;
        end
    end
endmodule
