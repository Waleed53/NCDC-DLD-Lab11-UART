`timescale 1ns/1ps

module uartTop(
    input  logic       bclk,
    input  logic       bclk8,
    input  logic       reset,
    input  logic [7:0] txData,
    input  logic       txSend,
    output logic       txBusy,
    output logic       txOut,
    input  logic       rxIn,
    output logic [7:0] rxData,
    output logic       rxReady,
    output logic       rxError
);

    uartTx txInst(
        .bclk(bclk),
        .reset(reset),
        .dataIn(txData),
        .send(txSend),
        .txLine(txOut),
        .busy(txBusy)
    );

    uartRx rxInst(
        .reset(reset),
        .bclk8(bclk8),
        .rx(rxIn),
        .dataOut(rxData),
        .ready(rxReady),
        .error(rxError)
    );

endmodule



module uartRx(
    input  logic        reset,
    input  logic        bclk8,   
    input  logic        rx,     
    output logic [7:0]  dataOut,
    output logic        ready,
    output logic        error
);

    typedef enum logic [1:0] {stIdle, stStart, stData, stStop} state_t;
    state_t state, nextState;

    logic [3:0] sampCnt, nextSampCnt;
    logic [2:0] bitIdx, nextBitIdx;  
    logic [7:0] shiftReg, nextShiftReg;
    logic       nextReady, nextError;

    always_comb begin
        nextState     = state;
        nextSampCnt   = sampCnt;
        nextBitIdx    = bitIdx;
        nextShiftReg  = shiftReg;
        nextReady     = 1'b0;
        nextError     = 1'b0;

        case (state)
            stIdle: begin
                if (rx == 1'b0) begin 
                    nextSampCnt = 4'd0;
                    nextState   = stStart;
                end
            end

            stStart: begin
                nextSampCnt = sampCnt + 1;
                if (sampCnt == 4) begin 
                    if (rx == 1'b0) begin
                        nextSampCnt  = 0;
                        nextBitIdx   = 0;
                        nextShiftReg = 8'b0;
                        nextState    = stData;
                    end else begin
                        nextState = stIdle; 
                    end
                end
            end

            stData: begin
                nextSampCnt = sampCnt + 1;
                if (sampCnt == 7) begin 
                    nextSampCnt  = 0;
                    nextShiftReg = {rx, shiftReg[7:1]};
                    if (bitIdx == 7) begin
                        nextState = stStop;
                    end else begin
                        nextBitIdx = bitIdx + 1;
                    end
                end
            end

            stStop: begin
                nextSampCnt = sampCnt + 1;
                if (sampCnt == 4) begin 
                    if (rx == 1'b1) begin
                        nextReady = 1'b1;
                        dataOut   = shiftReg; 
                    end else begin
                        nextError = 1'b1;
                    end
                    nextState = stIdle;
                end
            end
        endcase
    end

    always_ff @(posedge bclk8 or posedge reset) begin
        if (reset) begin
            state     <= stIdle;
            sampCnt   <= 0;
            bitIdx    <= 0;
            shiftReg  <= 8'b0;
            dataOut   <= 8'b0;
            ready     <= 1'b0;
            error     <= 1'b0;
        end else begin
            state     <= nextState;
            sampCnt   <= nextSampCnt;
            bitIdx    <= nextBitIdx;
            shiftReg  <= nextShiftReg;
            ready     <= nextReady;
            error     <= nextError;
        end
    end

endmodule

module uartTx(
    input  logic        bclk,    
    input  logic        reset,
    input  logic [7:0]  dataIn,
    input  logic        send,   
    output logic        txLine,  
    output logic        busy
);

  typedef enum logic [1:0] {stIdle, stStart, stData, stStop} statet;
    statet state, nextState;

    logic [9:0] shiftReg, nextShiftReg;
    logic [3:0] bitCnt, nextBitCnt;

    assign txLine = (state == stIdle) ? 1'b1 : shiftReg[0];
    assign busy   = (state != stIdle);

    always_comb begin
        nextState    = state;
        nextShiftReg = shiftReg;
        nextBitCnt   = bitCnt;

        case (state)
            stIdle:  if (send) begin
                         nextShiftReg = {1'b1, dataIn, 1'b0}; 
                         nextBitCnt   = 0;
                         nextState    = stStart;
                     end

            stStart: begin
                         nextShiftReg = {1'b1, shiftReg[9:1]};
                         nextBitCnt   = 1;
                         nextState    = stData;
                     end

            stData:  begin
                         nextShiftReg = {1'b1, shiftReg[9:1]};
                         if (bitCnt == 8)
                             nextState = stStop;
                         else
                             nextBitCnt = bitCnt + 1;
                     end

            stStop:  begin
                         nextShiftReg = {1'b1, shiftReg[9:1]};
                         nextState    = stIdle;
                     end
        endcase
    end

    always_ff @(posedge bclk or posedge reset) begin
        if (reset) begin
            state     <= stIdle;
            shiftReg  <= 10'b1111111111;
            bitCnt    <= 0;
        end else begin
            state     <= nextState;
            shiftReg  <= nextShiftReg;
            bitCnt    <= nextBitCnt;
        end
    end

endmodule
