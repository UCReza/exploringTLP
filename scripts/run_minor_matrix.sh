#!/usr/bin/env bash
set -euo pipefail
GEM5_ROOT="${GEM5_ROOT:?Set GEM5_ROOT=/abs/path/to/gem5}"
BIN="${BIN:?Set BIN=/abs/path/to/daxpy_aarch64}"
LABEL="${LABEL:-manual}"
N="${N:-1000000}"
A="${A:-2.5}"
cd "$GEM5_ROOT"
scons build/ARM/gem5.opt -j"$(sysctl -n hw.ncpu)"
for T in 1 2 4; do
  OUT="$GEM5_ROOT/results_${LABEL}/threads${T}"
  mkdir -p "$OUT"
  ./build/ARM/gem5.opt \
    --outdir="$OUT" \
    configs/deprecated/example/se.py \
    --cpu-type=MinorCPU \
    --num-cpus=1 \
    --caches --l2cache \
    --cmd="$BIN" \
    --options="$N $T $A"
  echo "Saved -> $OUT/stats.txt"
done
