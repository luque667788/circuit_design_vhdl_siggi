#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: run_ifx_reg_cell_tb.sh [--gui] [--clean]

Options:
  --gui    Launch GTKWave after the simulation finishes (if available).
  --clean  Remove existing work/results directories before running.
  -h, --help  Show this help message.
EOF
}

OPEN_GUI=false
CLEAN_BUILD=false

while (($# > 0)); do
  case "$1" in
    --gui)
      OPEN_GUI=true
      ;;
    --clean)
      CLEAN_BUILD=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
BUILD_DIR="${PROJECT_ROOT}/work"
RESULTS_DIR="${PROJECT_ROOT}/results"
VCD_FILE="${RESULTS_DIR}/ifx_reg_cell_tb.vcd"
EXE_FILE="${RESULTS_DIR}/ifx_reg_cell_tb"

if ${CLEAN_BUILD}; then
  rm -rf "${BUILD_DIR}" "${RESULTS_DIR}"
fi

mkdir -p "${BUILD_DIR}" "${RESULTS_DIR}"

pushd "${PROJECT_ROOT}" >/dev/null

GHDL_OPTS=(--std=08 --workdir="${BUILD_DIR}")
VHDL_SOURCES=(
  src/project_pkg.vhdl
  src/ifx_reg_cell_e.vhdl
  src/ifx_reg_cell_a.vhdl
  tb/ifx_reg_cell_tb.vhdl
)

echo "[INFO] Analyzing design"
for src_file in "${VHDL_SOURCES[@]}"; do
  ghdl -a "${GHDL_OPTS[@]}" "${src_file}"
done

echo "[INFO] Elaborating testbench"
ghdl -e "${GHDL_OPTS[@]}" -o "${EXE_FILE}" ifx_reg_cell_tb

echo "[INFO] Running simulation"
"${EXE_FILE}" --vcd="${VCD_FILE}"

popd >/dev/null

echo "[INFO] Waveform: ${VCD_FILE}"
if ${OPEN_GUI}; then
  if command -v gtkwave >/dev/null 2>&1; then
    gtkwave "${VCD_FILE}"
  else
    echo "[WARN] GTKWave not found on PATH; skipping GUI." >&2
  fi
else
  echo "[INFO] Skip GTKWave (use --gui to open)."
fi
