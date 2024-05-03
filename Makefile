SHELL := /bin/bash

.PHONY: all clean update-submodules

VIVADO_SETTINGS ?= ~/tools/Xilinx/Vivado/2023.2/settings64.sh
CONFIG ?= Rocket64b1gem4Chiffre
BOARD ?= vc707

clean:
	rm -rf ~/.ivy2/local/com.ibm/chiffre_*
	rm -rf vivado-risc-v/generators/chiffre
	rm -rf vivado-risc-v/lib/chiffre
	rm -rf vivado-risc-v/workspace/${CONFIG}

all: clean chiffre-publish le-chiffre
	cd vivado-risc-v && sbt clean && sbt update
	source ${VIVADO_SETTINGS}  && \
	export CLASSPATH=${CLASSPATH}:`realpath ~/.ivy2/local/com.ibm/chiffre_*/0.1-SNAPSHOT/jars/chiffre_*.jar` && \
	cd vivado-risc-v && \
	make CONFIG=${CONFIG} BOARD=${BOARD} vivado-project

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

apt-install:
	sudo apt install verilator yosys
