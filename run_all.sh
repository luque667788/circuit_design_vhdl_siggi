#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./run_all.sh [--gui] [--clean]

Runs all testbenches via their helper scripts in this order:
  1) run_ifx_reg_cell_tb.sh
  2) run_ifx_regfile_tb.sh
  3) run_integration_uart_core_tb.sh
  4) top_level_tb.sh

Options:
  --gui    Pass --gui to each testbench script (open GTKWave if available).
  --clean  Pass --clean to each testbench script (clean before run).
  -h, --help  Show this help.
EOF
}

OPEN_GUI=false
CLEAN_BUILD=false

while (($# > 0)); do
  case "$1" in
    --gui) OPEN_GUI=true ;;
    --clean) CLEAN_BUILD=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[ERROR] Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

run_tb() {
  local script="$1"
  local args=()
  if ${CLEAN_BUILD}; then args+=("--clean"); fi
  if ${OPEN_GUI}; then args+=("--gui"); fi
  echo "[INFO] Running ${script} ${args[*]:-}"
  "${PROJECT_ROOT}/${script}" "${args[@]}"
}

run_tb run_ifx_reg_cell_tb.sh
run_tb run_ifx_regfile_tb.sh
run_tb run_integration_uart_core_tb.sh
run_tb top_level_tb.sh

echo "[INFO] All testbenches completed."
