module baudGen (
    input  logic       clk, reset,     
  input  logic [1:0] select,      
    output logic       bclk,             // to transmitter
    output logic       bclk8           // to receiver
);

    logic [10:0] reg8, next8;
  logic [2:0] div8Count;

    int divisor;

    always_comb begin
        case (select)
            2'b00: divisor = 1302; // 9600
            2'b01: divisor = 651; // 19200
            2'b10: divisor = 326; // 38400
            default: divisor = 109; // 115200
        endcase
    end

    
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            reg8 <= 0;
        else
            reg8 <= next8;
    end

    //for bclk8
    assign next8 = (reg8 == divisor) ? 0 : reg8 + 1;

    // bclk8 tick
    assign bclk8 = (reg8 == 1);

  	// divide bclk8 by 8 to get bclk
    always_ff @(posedge clk, posedge reset) begin
    if (reset)
        div8Count <= 0;
    else if (bclk8)
        div8Count <= (div8Count == 3'd7) ? 3'd0 : div8Count + 1;
end

assign bclk = (bclk8 && (div8Count == 3'd7));

endmodule
