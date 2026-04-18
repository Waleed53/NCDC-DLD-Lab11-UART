`timescale 1ns/1ps

module uartTopTB();

    logic bclk;
    logic bclk8;
    logic reset;
    logic [7:0] txData;
    logic txSend;
    logic txBusy;
    logic txOut;
    logic rxIn;
    logic [7:0] rxData;
    logic rxReady;
    logic rxError;

    uartTop dut(
        .bclk(bclk),
        .bclk8(bclk8),
        .reset(reset),
        .txData(txData),
        .txSend(txSend),
        .txBusy(txBusy),
        .txOut(txOut),
        .rxIn(rxIn),
        .rxData(rxData),
        .rxReady(rxReady),
        .rxError(rxError)
    );

    initial begin
        bclk = 0;
        forever #50 bclk = ~bclk;
    end

    initial begin
        bclk8 = 0;
        forever #6.25 bclk8 = ~bclk8; 
    end

    initial begin
        $dumpfile("uartTop_tb.vcd");
        $dumpvars(0, uartTopTB);

        reset = 1;
        txSend = 0;
        txData = 8'h00;
        rxIn = 1;
        #100;
        reset = 0;

        #200;
        txData = 8'h41;
        txSend = 1; #100; txSend = 0;

        #2000;
        txData = 8'h42;
        txSend = 1; #100; txSend = 0;

        #2000;
        txData = 8'h43;
        txSend = 1; #100; txSend = 0;

        #2000;
        $finish;
    end

    always_comb rxIn = txOut;

endmodule
