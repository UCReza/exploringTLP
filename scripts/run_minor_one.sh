#!/usr/bin/env bash
set -euo pipefail
GEM5_ROOT="${GEM5_ROOT:?Set GEM5_ROOT=/abs/path/to/gem5}"
BIN="${BIN:?Set BIN=/abs/path/to/daxpy_aarch64}"
N="${N:-1000000}"
T="${T:-1}"
A="${A:-2.5}"
OUTDIR="${OUTDIR:-$GEM5_ROOT/m5out_minor_t$T}"
cd "$GEM5_ROOT"
scons build/ARM/gem5.opt -j"$(sysctl -n hw.ncpu)"
./build/ARM/gem5.opt \
  --outdir="$OUTDIR" \
  configs/deprecated/example/se.py \
  --cpu-type=MinorCPU \
  --num-cpus=1 \
  --caches --l2cache \
  --cmd="$BIN" \
  --options="$N $T $A"

echo "Stats:  $OUTDIR/stats.txt"
echo "Config: $OUTDIR/config.ini"
