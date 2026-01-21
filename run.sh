#!/usr/bin/env bash
set -euo pipefail

echo "Najla — Deterministic Core | quick test"
echo "--------------------------------------"

# Check tools
command -v iverilog >/dev/null 2>&1 || { echo "ERROR: iverilog not found"; exit 1; }
command -v vvp     >/dev/null 2>&1 || { echo "ERROR: vvp not found"; exit 1; }

# Ensure vectors are reachable with expected filenames
ln -sf vectors/ln.memh ln.memh
ln -sf vectors/log10.memh log10.memh
ln -sf vectors/x128_1024.memh x128_1024.memh

echo "[1/2] Accuracy (bit-exact)"
iverilog -g2012 -o acc.vvp tb/tb_accuracy_1024.sv rtl/najla_ln_package.sv
vvp -n acc.vvp

echo
echo "[2/2] Backpressure (bit-exact)"
iverilog -g2012 -o bp.vvp tb/tb_backpressure_1024.sv rtl/najla_ln_package.sv
vvp -n bp.vvp

echo
echo "DONE ✅"
