#!/usr/bin/env bash
set -euo pipefail


THE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SCRIPT_DIR="${THE_DIR/src}"
BUILD_DIR="${THE_DIR}/work"
RESULTS_DIR="${THE_DIR}/results"
VCD_FILE="${RESULTS_DIR}/ifx_regfile_tb.vcd"
EXE_FILE="${RESULTS_DIR}/ifx_regfile_tb"

mkdir -p "${BUILD_DIR}"
cd "${SCRIPT_DIR}"

echo "[INFO] Analyzing design"
ghdl -a --std=08 --workdir="${BUILD_DIR}" src/ifx_regfile_e.vhdl
ghdl -a --std=08 --workdir="${BUILD_DIR}" src/ifx_regfile_a.vhdl
ghdl -a --std=08 --workdir="${BUILD_DIR}" tb/ifx_regfile_tb.vhdl


echo "[INFO] Elaborating testbench"
ghdl -e --std=08 --workdir="${BUILD_DIR}" -o "${EXE_FILE}" ifx_regfile_tb


echo "[INFO] Running simulation"
"${EXE_FILE}" --vcd="${VCD_FILE}"

echo "[INFO] Waveform: ${VCD_FILE}"
if ! gtkwave "${VCD_FILE}"; then
	echo "[ERROR] Failed to launch GTKWave. Please ensure it is installed and in your PATH." >&2
	exit 1
fi
