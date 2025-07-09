module datamem(
    input logic clk,
    input logic rst_n,      
    input logic MemRead,
    input logic MemWrite,
    input logic [31:0] addr,
    input logic [31:0] WriteData,
    output logic [31:0] ReadData
);
    logic [31:0] memory [0:255];

    assign ReadData = (MemRead) ? memory[addr[9:2]] : 32'b0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 256; i = i + 1)
                memory[i] <= 32'b0;
        end else if (MemWrite) begin
            memory[addr[9:2]] <= WriteData;
        end
    end

    initial begin
        if ($fopen("./mem/dmem_init2.hex", "r"))
            $readmemh("./mem/dmem_init2.hex", memory);
        else if ($fopen("./mem/dmem_init.hex", "r"))
            $readmemh("./mem/dmem_init.hex", memory);
    end
endmodule
