`timescale 1ns/1ps

module tbUartRx();

    logic reset;
    logic bclk8;
    logic rx;
    logic [7:0] dataOut;
    logic ready;
    logic error;

    uartRx u(
        .reset(reset),
        .bclk8(bclk8),
        .rx(rx),
        .dataOut(dataOut),
        .ready(ready),
        .error(error)
    );


    initial begin
        bclk8 = 0;
        forever #1 bclk8 = ~bclk8;
    end

    initial begin
      $dumpfile("dump.vcd");
        $dumpvars(0, tbUartRx);

        reset = 1;
        rx = 1; 
        #200;
        reset = 0;
        #500;

      //0x41 ('A'), LSB first ---
        rx = 0; #(8*1);  

        rx = 1; #(8*1); 
        rx = 0; #(8*1);
        rx = 0; #(8*1); 
        rx = 0; #(8*1); 
        rx = 0; #(8*1); 
        rx = 0; #(8*1); 
        rx = 1; #(8*1);
        rx = 0; #(8*1); 

        rx = 1; #(8*1);

        #1000;

        $finish;
    end

endmodule
