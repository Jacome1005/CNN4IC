# CNN4IC
Convolutional Neural Network (CNN) for Image Classification


#### Created by:
- Jacobo Morales Erazo
- Mateo Fernandez Riveros
- Martín Calderón
- Hernando Diaz
- Daniel Pedraza

**Chapter/Section:** CASS Universidad de los Andes Student Chapter / Colombia Section


## Demos & Visualizations
Explore the project details and interactive simulations:
* [Interactive CNN Game](https://unic-cass-2025-uniandes.github.io/CNN4IC/html/cnn_game.html)
* [Architecture Diagram](https://unic-cass-2025-uniandes.github.io/CNN4IC/html/arch_diagram.html)
* [Dataset Cases](https://unic-cass-2025-uniandes.github.io/CNN4IC/html/dataset_casos.html)
* [CNN Architecture Details](https://unic-cass-2025-uniandes.github.io/CNN4IC/html/cnn_arch.html)


## Project Status & Implementation Metrics
**Last Update:** March 06, 2026

| Metric | Value |
| :--- | :--- |
| **Core Dimensions** | $\approx 503\ \mu m \times 504\ \mu m$ |
| **Die (Chip) Dimensions** | $\approx 515\ \mu m \times 534\ \mu m$ |
| **Logic Area** | $\approx 135,000\ \mu m^2$ |
| **Total Chip Area** | $\approx 0.27\ mm^2$ |

### Physical Layout & Dimensions
<img src="docs/assets/gds_dimentions.png" width="500px" alt="GDS Dimensions">


## Design Concept: Lightweight Binary Shape Classifier
This Integrated Circuit (IC) implements a specialized, resource-optimized Convolutional Neural Network (CNN) designed specifically for the low-power discrimination of geometric primitives (crosses and plus signs). 

### Architecture and Data Flow
The system processes 3-bit grayscale images with **10×10** dimensions.

1. **Image Input:** Data is loaded row-by-row via **SPI** into a bank of 10 dedicated image registers (30 bits each).
2. **Convolution:** Executed sequentially by the same datapath using two independently loaded kernels ($W_{+}$ and $W_{\times}$). For each kernel, the 10×10 image is partitioned into 9 overlapping 6×6 fragments (stride = 2). Within each fragment, the 4 valid 5×5 windows are evaluated by a fully parallel MAC unit operating on signed 3-bit operands.
3. **Max Pooling:** Applied per-fragment: the maximum convolution result across the 4 windows is retained by a progressive comparator. The 9 fragment maxima are then accumulated into a single signed 16-bit score per kernel ($\text{acc}_0$, $\text{acc}_1$).
4. **Classification:** Determined by a combinational signed comparator operating on the two accumulated scores:

$$\text{Class} = \begin{cases} 0 \ (+) & \text{if } \text{acc}_0 > \text{acc}_1 \\ 1 \ (\times) & \text{otherwise} \end{cases}$$

### Hardware Optimization
The core innovation lies in **Strict Bit-Width Management**:
- **Weight Precision:** 3-bit signed fields for all kernel positions, enabling compact 15-bit per-row register storage.
- **Integer Domain:** All arithmetic is performed on signed integers synthesized from the 3-bit operand widths.
- **Sequential Kernel Reuse:** A single convolutional datapath is time-multiplexed across both kernels, significantly reducing area relative to a parallel dual-kernel architecture.
- **Area Efficiency:** By streaming results externally via SPI, the silicon footprint is reduced to $0.27\ \text{mm}^2$.

### Serial Interface (SPI)
A 4-wire protocol with an 8-command space distinguishes between:

| Command | Code | Description |
|---|---|---|
| LOAD IMAGE | `001` | Streams 10 rows × 30 bits into image registers |
| LOAD WEIGHTS | `010` | Streams 5 rows × 15 bits into kernel registers |
| START CNN | `011` | Triggers one sequential inference pass |
| READ RESULT | `100` | Returns 1-bit classification output via MISO |
| READ MR1 | `101` | Returns 16-bit accumulated score for kernel 0 |
| READ MR2 | `110` | Returns 16-bit accumulated score for kernel 1 |

A typical inference cycle requires two START pulses: the first processes $W_{+}$ and latches $\text{acc}_0$; the second processes $W_{\times}$ and latches $\text{acc}_1$. The kernel registers are reloaded by the host MCU between the two passes.

Unlike fixed logic implementations, this architecture employs a dynamic weight scheme via SPI, transforming the IC into a general-purpose classifier for 10x10 patterns. This capability allows the chip to be reprogrammed in real time for diverse low-power computer vision applications beyond the discrimination of crosses.
