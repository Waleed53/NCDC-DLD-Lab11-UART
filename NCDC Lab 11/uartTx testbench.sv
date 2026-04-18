`timescale 1ns/1ps

module uartTxTB();

    logic bclk;
    logic reset;
    logic [7:0] dataIn;
    logic send;
    logic txLine;
    logic busy;

    uartTx dut(
        .bclk(bclk),
        .reset(reset),
        .dataIn(dataIn),
        .send(send),
        .txLine(txLine),
        .busy(busy)
    );

    initial begin
        bclk = 0;
        forever #50 bclk = ~bclk;
    end

    initial begin
        $dumpfile("uartTx_tb.vcd");
        $dumpvars(0, uartTxTB);

        reset = 1;
        send = 0;
        dataIn = 8'h00;
        #100;
        reset = 0;

        #200;
        dataIn = 8'h41;
        send = 1; #100; send = 0;

        #2000;
        dataIn = 8'h42;
        send = 1; #100; send = 0;

        #2000;
        dataIn = 8'h43;
        send = 1; #100; send = 0;

        #2000;
        $finish;
    end

endmodule
