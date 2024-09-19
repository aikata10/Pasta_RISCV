# RISC V INTEGRATION WITH CIPHER PASTA

This project integrates the Cipher Pasta as a peripheral in a RISC-V architecture. The project works for post-sythesis simulation in 130nm technology node and requires 1.8 mm2 (4.6 mm2 with Ibex core).

## Requirements

### Tools
- **Simulation**: Cadence NCSim (or Modelsim)
- **Synthesis**: Cadence Genus (2019.11)

### Environment
- Ensure the Cadence tools are properly installed and configured.
- Access to the standard cell libraries for the chosen technology node.

## Usage Instructions

### Simulation
1. Load your RTL code (Verilog, SystemVerilog) into the simulation tool.
2. Configure **NCSim** or **Modelsim** to run the functional simulation.
3. Verify the simulated signals to ensure that the design behaves as expected.
4. Software side implementaion is in the folder src/sw.

### Synthesis
1. Load your RTL code into **Cadence Genus**.
2. Set the area and timing constraints before running synthesis.
3. Run the synthesis process to generate the gate-level netlist.
4. Verify the post-synthesis simulation signals to ensure that the design behaves as expected.
5. Software side implementaion is in the folder src/sw.

### HW-design codes

The hardware design codes are present in the `./src/sv/` and `./src/sv/pasta\_src/` folders. Its testbench is in the `./src/tb/` folder. The Software portion of the files, utilized for testing the en/decryption, are present in the `./src/sw/Cipher/` folder. The remaining folder- `./src/ibex/` contains ibex related default files. 


