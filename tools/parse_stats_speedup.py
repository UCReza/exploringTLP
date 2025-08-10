#!/usr/bin/env python3
import os, re, csv
from collections import defaultdict
ROOT = os.path.expanduser(os.environ.get("ROOT", "."))
GEM5_ROOT = os.path.expanduser(os.environ.get("GEM5_ROOT", ""))
roots = []
if GEM5_ROOT and os.path.isdir(GEM5_ROOT):
    roots = [os.path.join(GEM5_ROOT, d) for d in os.listdir(GEM5_ROOT) if d.startswith("results_")]
    roots = [r for r in roots if os.path.isdir(r)]
else:
    roots = [ROOT]
rows = []
for base in roots:
    for root, _, files in os.walk(base):
        if "stats.txt" not in files: continue
        rel = os.path.relpath(root, base)
        threads = rel.replace("threads","") if rel.startswith("threads") else ""
        label = os.path.basename(base).replace("results_", "")
        simSeconds = ipc = cpi = ""
        with open(os.path.join(root, "stats.txt")) as f:
            for line in f:
                if line.startswith("simSeconds"): simSeconds = line.split()[-1]
                elif line.startswith("system.cpu.ipc"): ipc = line.split()[-1]
                elif line.startswith("system.cpu.cpi"): cpi = line.split()[-1]
        rows.append({"label":label,"threads":threads,"simSeconds":simSeconds,"ipc":ipc,"cpi":cpi,"folder":root})
by_label = defaultdict(list)
for r in rows: by_label[r["label"]].append(r)
for lab, arr in by_label.items():
    base = next((x for x in arr if x["threads"]=="1" and x["simSeconds"]), None)
    bt = float(base["simSeconds"]) if base else None
    for x in arr:
        x["speedup_vs_1"] = str(bt/float(x["simSeconds"])) if bt and x["simSeconds"] else ""
rows.sort(key=lambda r:(r["label"], int(r["threads"] or 0)))
out_csv = os.path.join(GEM5_ROOT if GEM5_ROOT else ".", "results_summary_with_speedup.csv")
with open(out_csv, "w", newline="") as f:
    w=csv.DictWriter(f, fieldnames=["label","threads","simSeconds","ipc","cpi","speedup_vs_1","folder"])
    w.writeheader(); w.writerows(rows)
print(f"Wrote {out_csv} with {len(rows)} rows.")
