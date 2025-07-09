module alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  ALUOp,
    output logic [31:0] Result,
    output logic Zero
);
    always @(*) begin
        case (ALUOp)
            4'b0000: Result = A + B;
            4'b0001: Result = A - B;
            4'b0010: Result = A & B;
            4'b0011: Result = A | B;
            4'b0100: Result = A ^ B;
            4'b0101: Result = A << B[4:0];
            4'b0110: Result = A >> B[4:0];
            4'b0111: Result = $signed(A) >>> B[4:0];
            4'b1000: Result = ($signed(A) < $signed(B)) ? 1 : 0;
            4'b1001: Result = (A < B) ? 1 : 0;
            default: Result = 32'b0;
        endcase
    end

    assign Zero = (Result == 32'b0);
endmodule

