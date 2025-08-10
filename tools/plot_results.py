#!/usr/bin/env python3
import os, csv, collections
import matplotlib.pyplot as plt
CSV = os.path.expanduser(os.environ.get("CSV", "results_summary_with_speedup.csv"))
OUT = os.path.expanduser(os.environ.get("OUT", "plots"))
os.makedirs(OUT, exist_ok=True)
rows = []
with open(CSV) as f:
    for r in csv.DictReader(f):
        try:
            rows.append({"label":r["label"],"threads":int(r["threads"] or 0),"simSeconds":float(r["simSeconds"] or 0.0),"speedup":float(r["speedup_vs_1"] or 0.0) if r["speedup_vs_1"] else None})
        except: pass
by_label = collections.defaultdict(list)
for r in rows: by_label[r["label"]].append(r)
for lab, arr in sorted(by_label.items()):
    arr.sort(key=lambda x:x["threads"])
    xs=[x["threads"] for x in arr if x["threads"]>0]
    ys=[x["simSeconds"] for x in arr if x["threads"]>0]
    ysp=[x["speedup"] for x in arr if x["threads"]>0 and x["speedup"] is not None]
    plt.figure(); plt.plot(xs,ys,marker="o"); plt.title(f"{lab}: simSeconds vs Threads"); plt.xlabel("Threads"); plt.ylabel("simSeconds"); plt.grid(True,linestyle="--",alpha=0.5); plt.savefig(os.path.join(OUT,f"{lab}_simSeconds_vs_threads.png"),dpi=150,bbox_inches="tight"); plt.close()
    if any(ysp): plt.figure(); plt.plot(xs,ysp,marker="o"); plt.title(f"{lab}: Speedup vs Threads (baseline T=1)"); plt.xlabel("Threads"); plt.ylabel("Speedup"); plt.grid(True,linestyle="--",alpha=0.5); plt.savefig(os.path.join(OUT,f"{lab}_speedup_vs_threads.png"),dpi=150,bbox_inches="tight"); plt.close()
print(f"Saved plots to {OUT}")
