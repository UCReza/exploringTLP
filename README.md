# MinorCPU Part 2 — Updated Pack

Place in: ~/work/gem5_part2

1) Build binary inside Docker:
   cd ~/work/gem5_part2
   ./scripts/build_arm_in_docker.sh

2) Edit Minor latencies in your gem5 (example):
   ~/Gem5/gem5/src/cpu/minor/BaseMinorCPU.py
   class MinorDefaultFloatSimdFU(MinorFU):
       opLat = X
       issueLat = Y   # ensure X+Y = 7

3) Run T=1,2,4 for a labeled pair:
   GEM5_ROOT="~/Gem5/gem5" BIN="~/work/gem5_part2/daxpy_aarch64" LABEL="op3_iss4"      ~/work/gem5_part2/scripts/run_minor_matrix.sh

4) Summarize & plot:
   GEM5_ROOT="~/Gem5/gem5" python3 ~/work/gem5_part2/tools/parse_stats_speedup.py
   CSV="~/Gem5/gem5/results_summary_with_speedup.csv" OUT="~/Gem5/gem5/plots"      python3 ~/work/gem5_part2/tools/plot_results.py
