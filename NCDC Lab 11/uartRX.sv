`timescale 1ns/1ps

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
