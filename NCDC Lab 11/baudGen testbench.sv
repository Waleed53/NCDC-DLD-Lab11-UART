
`timescale 1ns/1ps

module baudGenTB();
  logic sysClk, reset;
  logic [1:0] selBaud;
  logic bclk, bclk8;

  baudGen u(.clk(sysClk),.reset(reset), .select(selBaud), .bclk(bclk), .bclk8(bclk8));

  initial begin
    sysClk = 0;
    forever #1 sysClk = ~sysClk;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    reset = 1;
    #10
    reset = 0;
    #10
    selBaud = 2'b00; // 9600 baud
    #100000;

    $finish;
  end
endmodule
