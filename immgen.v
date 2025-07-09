module immgen(
    input  logic [31:0] inst,
    output logic [31:0] imm_out
);
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            7'b0000011, // I-type
            7'b0010011,
            7'b1100111:
                imm_out = {{20{inst[31]}}, inst[31:20]};

            7'b0100011: // S-type
                imm_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            7'b1100011: // B-type
                imm_out = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};

            7'b0010111, // auipc
            7'b0110111: // lui
                imm_out = {inst[31:12], 12'b0};

            7'b1101111: // jal
                imm_out = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

            default:
                imm_out = 32'b0;
        endcase
    end
endmodule

