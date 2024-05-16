SHELL := /bin/bash

.PHONY: all clean update-submodules

VIVADO_SETTINGS ?= ${HOME}/tools/Xilinx/Vivado/2023.2/settings64.sh
CONFIG ?= Rocket64b1gem4Chiffre
BOARD ?= vc707
ROCKETCHIP_DIR = $(abspath ./vivado-risc-v/rocket-chip)
INCLUDE_DIR = $(abspath .)
RISCV_PREFIX = /opt/riscv
RISC_V_BIN = $(RISCV_PREFIX)/bin


export FIRRTL = java -Xmx12G -Xss8M $(JAVA_OPTIONS) -cp "`realpath target/scala-*/system.jar`:${CLASSPATH}" firrtl.stage.FirrtlMain --custom-transforms=chiffre.passes.FaultInstrumentationTransform -ll Info


clean:
	rm -rf ~/.ivy2/local/com.ibm/chiffre_*
	rm -rf vivado-risc-v/generators/chiffre
	rm -rf vivado-risc-v/lib/chiffre
	rm -rf vivado-risc-v/workspace/${CONFIG}
	

vivado-project: clean chiffre-publish le-chiffre
	cd vivado-risc-v && sbt clean && sbt update
	source ${VIVADO_SETTINGS}  && \
	export CLASSPATH=${CLASSPATH}:`realpath ~/.ivy2/local/com.ibm/chiffre_*/0.1-SNAPSHOT/jars/chiffre_*.jar` && \
	cd vivado-risc-v && \
	$(MAKE) CONFIG=${CONFIG} BOARD=${BOARD} vivado-project


vivado-project-test: clean chiffre-publish le-chiffre
	export CONFIG=LeChiffreConfig && \
	$(MAKE) vivado-project
	
risc-v-tools: 
	sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev
	cd ~/Downloads && \
	git clone https://github.com/riscv/riscv-gnu-toolchain && \
	cd riscv-gnu-toolchain && \
	./configure --prefix=$(RISCV_PREFIX) && \
	$(MAKE)
	rm -rf Downloads/riscv-gnu-toolchain

start-vivado:
	source ${VIVADO_SETTINGS}  && vivado


run-test:
	cd chiffre/tests/smoke && export INCLUDE_DIR=${INCLUDE_DIR} && $(MAKE) && cd build && cp boot.elf /media/rob/BOOT/
	
	

update-submodules:
	git submodule init && git submodule update --init --recursive

# there are multiple ways to include the Chiffre tool in the project:
chiffre-lib:
	cd chiffre && sbt assembly # creates a jar containing the Chiffre tool
	mkdir -p vivado-risc-v/lib/ && cp chiffre/utils/bin/chiffre.jar vivado-risc-v/lib

chiffre-generator:
	rm -rf vivado-risc-v/generators/chiffre
	cp -r chiffre vivado-risc-v/generators/chiffre

chiffre-publish:
	cd chiffre && sbt publishLocal # publishes the Chiffre tool to the local Ivy repository

le-chiffre: chiffre-publish
	rm -rf vivado-risc-v/rocket-chip/src/main/scala/leChiffre && cp -r chiffre/leChiffre vivado-risc-v/rocket-chip/src/main/scala/

apt-install: risc-v-tools
	sudo apt install verilator yosys gcc-riscv64-unknown-elf
