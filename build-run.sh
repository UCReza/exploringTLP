#!/bin/bash
set -e

# === CONFIGURATION ===
GEM5_ROOT="/Users/rezashrestha/Documents/MSCS-531/Gem5/gem5"                     # <-- change this to your gem5 repo
BIN="/Users/rezashrestha/Documents/MSCS-531/Week7/work/daxpy_aarch64"  # <-- change this to your daxpy binary

N=1000000   # vector size
T=4         # threads
A=2.5       # scalar multiplier

# === BUILD GEM5 (ARM) ===
cd "$GEM5_ROOT"
echo "Rebuilding gem5..."
scons build/ARM/gem5.opt -j"$(sysctl -n hw.ncpu)"

# === RUN WORKLOAD ===
echo "Running daxpy with N=$N, T=$T, A=$A..."
./build/ARM/gem5.opt configs/example/se.py \
  --cpu-type=MinorCPU \
  --num-cpus=1 \
  --cmd="$BIN" \
  --options="$N $T $A"

# === SHOW RESULTS ===
echo
echo "Run complete."
echo "Stats:   $GEM5_ROOT/m5out/stats.txt"
echo "Config:  $GEM5_ROOT/m5out/config.ini"



