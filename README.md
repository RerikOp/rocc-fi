# rocc-fi

# Build risc-v tools
Either run `make risc-v-tools`, which can take a while. Alternatively, download the nighly build for your operating system: https://github.com/riscv-collab/riscv-gnu-toolchain/releases/.
Set the RISCV_PREFIX accordingly. If you run with -nostartfiles, you should be okay with the risc-v gcc that is installed with apt, as it does not come with crt0.o, which implements _start


# Generate Bitstream for ZCU104:
1. In vivado change part to ZCU104 (TODO: Config in TCL script): Settings > General > Project device 
2. In TCL console, source ${PROJECT_ROOT}/vivado-risc-v/board/zcu104/update_BD_vc707_to_zcu104.tcl (source /home/rob/Documents/rocc-fi/vivado-risc-v/board/zcu104/update_BD_vc707_to_zcu104.tcl)


# Run Chiffre Test:
First, make sure that cable drivers are installed (https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Installing-Cable-Drivers) and source Vivado Settings (source ~/tools/Xilinx/Vivado/2023.2/settings64.sh).

1. Flash Bitstream: Open Hardware Manager and auto connect. Then program device
2. Run xsdb and connect, see (https://github.com/eugene-tarassov/vivado-risc-v/tree/v3.7.0/bare-metal)
3. Open GTKTerm as sudo and select Port (Configuration > Port). Usually you can find the FPGA on usb3 (or not).

