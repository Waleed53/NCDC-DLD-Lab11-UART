# NCDC DLD Module — Lab 11: UART

## Course
**NCDC Cohort 02/2025 — Design Verification (DV)**
NUST Chip Design Centre (NCDC), NUST

## Module
**Digital Logic Design (DLD) Module** — Lab 11

---

## Overview

This lab implements a complete **UART (Universal Asynchronous Receiver-Transmitter)** communication system from scratch in **SystemVerilog**. UART is one of the most fundamental serial communication protocols in embedded systems and digital design, enabling full-duplex asynchronous data transfer between devices using just two data lines (TX and RX).

---

## UART Protocol Background

UART transmits data as a series of bits at a fixed baud rate (bits per second) without a shared clock signal:

| Field | Duration | Description |
|-------|----------|-------------|
| **Start bit** | 1 bit | Always LOW — signals frame start |
| **Data bits** | 8 bits | LSB first — the payload byte |
| **Stop bit** | 1 bit | Always HIGH — signals frame end |

The receiver samples each bit in the middle of its time window, requiring both ends to agree on the baud rate.

---

## Module Descriptions

### baudGen.sv
Generates the **baud rate clock** by counting system clock cycles. For a 50 MHz system clock and 9600 baud rate, the divider counts to 5208. The mid-sample tick is generated at the halfway point for accurate data sampling.

### uartTx.sv
The **transmitter module**: accepts an 8-bit parallel data byte, serialises it, and outputs the UART frame (start bit + 8 data bits + stop bit) on the TX line at the configured baud rate. Uses a shift register and a state machine (IDLE → START → DATA → STOP).

### uartRX.sv
The **receiver module**: monitors the RX line for the falling edge of the start bit, then samples subsequent bits at the mid-baud-tick to reconstruct the original byte. Outputs a valid pulse and the received parallel data byte when a complete frame is detected.

### toplevel.sv
The **top-level integration**: wires the baud rate generator, transmitter, and receiver together. Supports loopback testing (TX connected to RX) for self-verification.

---

## Repository Structure

```
NCDC Lab 11/
├── baudGen.sv                   # Baud rate clock generator
├── baudGen testbench.sv         # Testbench — verifies tick timing at various baud rates
├── uartTx.sv                    # UART transmitter (parallel-in, serial-out)
├── uartTx testbench.sv          # Testbench — verifies TX frame format
├── uartRX.sv                    # UART receiver (serial-in, parallel-out)
├── uartRX testbench.sv          # Testbench — verifies RX sampling and framing
├── toplevel.sv                  # Top-level integration (TX + RX + baudGen)
├── toplevel testbench.sv        # Integration testbench — end-to-end UART test
├── Waveform for baudRateGen.png # Simulation waveform — baud tick verification
├── Waveform of tx module.png    # Simulation waveform — TX serial output
├── Waveform of rx module.png    # Simulation waveform — RX deserialization
└── waveform of toplevel.png     # Simulation waveform — full loopback test
NCDC_Lab11_report.pdf            # Full lab report
```

---

## Simulation

```bash
# Compile and simulate with ModelSim / QuestaSim
vlog *.sv
vsim "baudGen testbench" -do "run -all"
vsim "uartTx testbench" -do "run -all"
vsim "uartRX testbench" -do "run -all"
vsim "toplevel testbench" -do "run -all"
```

---

## Concepts Demonstrated
- Asynchronous serial communication protocol (UART) from scratch
- Baud rate clock generation with configurable divisor
- Shift-register-based serialiser (TX) and deserialiser (RX)
- Mid-bit sampling for robust asynchronous reception
- FSM-based datapath control (IDLE/START/DATA/STOP states)
- End-to-end loopback verification in simulation
