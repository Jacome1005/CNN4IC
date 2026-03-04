# CNNver2 — Complete Technical Documentation
## Convolutional Neural Network in Verilog (FPGA)



CNNver2 is a hardware CNN accelerator implemented in Verilog and designed to run on an FPGA. It performs a 2D convolution of a 10×10 image (3 bits per pixel) with a 5×5 kernel (3 bits per weight), followed by MaxPooling and accumulation of results.

Communication with external devices is done exclusively through **SPI** (Serial Peripheral Interface), which makes the system compatible with microcontrollers and embedded systems.

---

## System Modules

```
| Module | Description |
|---|---|
| CNNver2 | Top Module — connects all blocks |
| spi_cnn_slave_8 | SPI slave — receives commands and data |
| Register_Imag ×10 | Image registers (30 bits each) |
| Register_Weight ×5 | Weight registers (15 bits each) |
| SC_STATEMACHINE_CNN_CTRL | Main CNN control FSM |
| SC_STATEMACHINE_IMAGE_LOADER | Image row loader FSM |
| SC_STATEMACHINE_WEIGHT_LOADER | Weight row loader FSM |
| cnn_conv_v2 | Convolution wrapper |
| cnn_v2 | 5×5 convolution core (2-cycle pipeline) |
| maxpool_shift | Shift register with comparator chain (max of 4) |
| accum_maxpool | MaxPool accumulator (20 bits) |
| Master_register (×3) | Main result register, MR1 and MR2 |
| result_mux_4to1 | 4:1 result selector mux |
```

---

# System Pins (Top Module)

```
╔════════════════════════════════════════════════════════╗
║                     CNNver2                           ║
║                   (Top Module)                        ║
║                                                       ║
║  INPUTS:                          OUTPUT:             ║
║  ─────────────────────────────    ──────────────────  ║
║  CNNver2_SPICLOCK_50 ──► CLK      MISO ──► result     ║
║  CNNver2_SS_N ────────► CS_n            (SPI serial)  ║
║  CNNver2_MOSI ────────► MOSI                          ║
║  CNNver2_Reset_InHigh ► RST                           ║
║  CNNver2_CMD_Reset ───► CMD_RST                       ║
╚════════════════════════════════════════════════════════╝
```

## Pin Table

```
| Pin | Direction | Description |
|---|---|---|
| CNNver2_MISO | Output | SPI serial data to the Master (CNN result) |
| CNNver2_SPICLOCK_50 | Input | SPI clock (also system global clock) |
| CNNver2_SS_N | Input | Active-low Chip Select (starts SPI transaction) |
| CNNver2_MOSI | Input | Data/commands from the SPI Master |
| CNNver2_Reset_InHigh | Input | Global system reset (active high) |
| CNNver2_CMD_Reset | Input | Aborts the current SPI command (does not clear results) |
```

---

# General Architecture — Block Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           CNNver2 (Top Module)                           │
│                                                                          │
│  External SPI Master                                                     │
│  MOSI ──► ┌─────────────────┐                                            │
│  MISO ◄── │  spi_cnn_slave  │ cmd[2:0]                                   │
│  CLK  ──► │      _8         │                                            │
│  CS_n ──► └────────┬────────┘                                            │
│                    │                                                     │
│         ┌──────────┴─────────────────────────────┐                       │
│         │                                        │                       │
│    Image (30b×10)                         Weights (15b×5)                │
│         │                                        │                       │
│   ┌─────▼──────┐                        ┌────────▼───────┐               │
│   │ Reg_Imag   │ (×10 registers)        │  Reg_Weight    │ (×5 regs)     │
│   │  30 bits   │                        │   15 bits      │               │
│   └─────┬──────┘                        └────────┬───────┘               │
│         │ px_flat[299:0]                          │ w_flat[74:0]         │
│         └──────────────────┬────────────────────┘                        │
│                            │                                             │
│                    ┌───────▼────────┐                                    │
│                    │   cnn_conv_v2  │  ← SC_STATEMACHINE_CNN_CTRL        │
│                    │   (cnn_v2)     │    (control FSM)                   │
│                    │  2-cycle pipe  │                                    │
│                    └───────┬────────┘                                    │
│                            │ y_out[10:0] (signed)                         │
│                    ┌───────▼────────┐                                    │
│                    │ result_mux_4to1│                                    │
│                    └───────┬────────┘                                    │
│                            │                                             │
│                    ┌───────▼────────┐                                    │
│                    │ Master_register│ → MISO (cmd 011: READ RESULT)      │
│                    │   (16 bits)    │                                    │
│                    └────────────────┘                                    │
│                                                                          │
│  MaxPool path:                                                           │
│  MOSI──►spi_slave──►maxpool_shift──►accum_maxpool──►MR1/MR2──►compare   │
└──────────────────────────────────────────────────────────────────────────┘
```

---

# SPI Protocol — Commands

The first **3 bits** received on MOSI define the command.

```
MOSI frame: [CMD[2] CMD[1] CMD[0] | DATA...]
              ───────────────────   ───────────
              3 command bits        Payload data
```

```
| Cmd | Name | Description |
|-----|------|-------------|
| 000 | LOAD_IMAGE | Load full 10×10 image |
| 001 | LOAD_WEIGHTS | Load 5×5 kernel |
| 010 | START_CNN | Start convolution |
| 011 | READ_RESULT | Read CNN result |
| 100 | LOAD_MAXPOOL | Load 4 values for MaxPool |
| 101 | SAVE_ACCUM | Save accumulator into MR1/MR2 |
| 110 | READ_COMPARE | Read MR1 > MR2 comparison |
```

---

# FSM State Diagram

```
                    ┌───────────────────────────────┐
                    │                               │
                    ▼                               │
              ┌─────────┐                           │
         ┌─►  │  IDLE   │  ◄────────────────────┐   │
         │    └────┬────┘                        │  │
         │         │                             │  │
         │    ┌────┴────────────┐                │  │
         │    │                 │                │  │
         │  start_cnn_latch  save_accum_latch    │  │
         │    │                 │                │  │
         │    ▼                 ▼                │  │
         │  ┌────┐        ┌──────────┐           │  │
         │  │LOAD│        │SAVE_ACCUM│ ──────────┘  │
         │  └──┬─┘        └──────────┘              │
         │     │                                    │
         │     ▼                                    │
         │  ┌─────┐                                 │
         │  │PIPE1│                                 │
         │  └──┬──┘                                 │
         │     │                                    │
         │     ▼                                    │
         │  ┌─────┐ ◄────────────┐                  │
         │  │PIPE2│              │                  │
         │  └──┬──┘   ready=0   │                   │
         │     │ ready=1         │                  │
         │     ▼                                    │
         │  ┌─────────────┐                         │
         └─ │ CAPTURE_CNN │ ────────────────────────┘
            └─────────────┘
```

---

# System Registers

```
┌──────────────────────────────────────────────────────────────────────┐
│                       SYSTEM REGISTERS                               │
│                                                                      │
│  IMAGE (10 × 30 bits):                                               │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │ Reg_Imag[0] │ Reg_Imag[1] │ ... │ Reg_Imag[9] │ (30b each)    │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                        ↕ px_flat[299:0]                              │
│                                                                      │
│  KERNEL (5 × 15 bits):                                               │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │ Wgt[0] │ Wgt[1] │ Wgt[2] │ Wgt[3] │ Wgt[4] │ (15b each) │        │
│  └──────────────────────────────────────────────────────────┘        │
│                        ↕ w_flat[74:0]                                │
│                                                                      │
│  CNN RESULT (1 × 16 bits):                                           │
│  ┌────────────────────────┐                                          │
│  │ Master_register (MR)   │ → MISO (cmd 011)                         │
│  └────────────────────────┘                                          │
│                                                                      │
│  MAXPOOL ACCUMULATION (2 × 20 bits):                                 │
│  ┌──────────────────────┐  ┌──────────────────────┐                  │
│  │ Master_register MR1 │  │ Master_register MR2 │                  │
│  └──────────────────────┘  └──────────────────────┘                  │
│        → comparison bit → MISO (cmd 110)                             │
└──────────────────────────────────────────────────────────────────────┘
```

---

# Working Sequence

### Step 1 — LOAD_IMAGE (cmd 000)

```
[000][Row0_30b]...[Row9_30b]
```

→ Image registers loaded  
→ px_flat valid

---

### Step 2 — LOAD_WEIGHTS (cmd 001)

```
[001][Wrow0_15b]...[Wrow4_15b]
```

→ Weight registers loaded  
→ w_flat valid

---

### Step 3 — START_CNN (cmd 010)

→ FSM runs  
IDLE → LOAD → PIPE1 → PIPE2 → CAPTURE_CNN → IDLE  
→ Convolution finished in 2 cycles  
→ Result stored in Master_register

---

### Step 4 — READ_RESULT (cmd 011)

```
[011] + 16 dummy clocks
```

→ MISO outputs 16-bit signed result

---

### Step 5 — LOAD_MAXPOOL (cmd 100)

```
[100][V0][V1][V2][V3]
```

→ Max of 4 values  
→ Accumulated into 20-bit register

---

### Step 6 — SAVE_ACCUM (cmd 101)

First call → save to MR1  
Second call → save to MR2

---

### Step 7 — READ_COMPARE (cmd 110)

→ MISO = 1 if MR1 > MR2  
→ MISO = 0 otherwise

---

# End-to-End Flow

```
Image + Kernel
      │
LOAD_IMAGE + LOAD_WEIGHTS
      │
START_CNN
      │
cnn_v2 (2 cycles)
      │
Master_register
      │
READ_RESULT → MISO
```

---

# Implementation Notes

```
| Item | Detail |
|------|--------|
| Clock domain | single clock |
| CNN latency | 2 cycles |
| Accumulator overflow | impossible (20 bits enough) |
| Max convolution value | ±400 |
| MISO | tri-state when inactive |
| FSM priority | START_CNN > SAVE_ACCUM |
```

---

# End of Document
