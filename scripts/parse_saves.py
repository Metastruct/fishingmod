#!/usr/bin/env python3

# written with opencode big pickle (to unbreak saves) for https://github.com/Metastruct/fishingmod/issues/30

"""Parse fishingmod binary save files and find max rod length."""
import struct
from pathlib import Path
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument("--path", default=str(Path.home() / "srcds/garrysmod/data/fishingmod"))
parser.add_argument("--file")
parser.add_argument("--json", action="store_true")
parser.add_argument("--rename-suspicious", action="store_true")
args = parser.parse_args()

def parse_save(path):
    raw = path.read_bytes()
    if not raw:
        return None
    ver = raw[0]
    if len(raw) != 57:
        print(f"Unexpected size {len(raw)} bytes (expected 57) in {path}") if ver == 0x01 else None
        return None
    if ver != 0x01:
        print(f"Unknown version 0x{ver:02x} in {path}")
        return None
    fields = ["catches", "exp", "money", "length", "reel_speed", "string_length", "force"]
    vals = {}
    for i, name in enumerate(fields):
        vals[name] = struct.unpack_from("<d", raw, 1 + i * 8)[0]
    return vals

def print_data(data, label):
    print(f"--- {label} ---")
    for k, v in data.items():
        print(f"  {k}: {v}")

if args.file:
    data = parse_save(Path(args.file))
    if data:
        print_data(data, args.file)
    else:
        print("Not a valid v4 save file.")
    raise SystemExit(0)

DATA_DIR = Path(args.path)
results = []

def scan_dir(steam_dir):
    for c_dir in sorted(steam_dir.iterdir()):
        if c_dir.name == "1":
            for d_dir in sorted(c_dir.iterdir()):
                for fpath in sorted(d_dir.glob("*.txt")):
                    data = parse_save(fpath)
                    if data:
                        already = fpath.name.endswith(".sus.txt")
                        rel = fpath.relative_to(DATA_DIR)
                        results.append((data["length"], data["money"], rel, data, fpath, already))
        else:
            for fpath in sorted(c_dir.glob("*.txt")):
                data = parse_save(fpath)
                if data:
                    already = fpath.name.endswith(".sus.txt")
                    rel = fpath.relative_to(DATA_DIR)
                    results.append((data["length"], data["money"], rel, data, fpath, already))

for steam_dir in sorted(DATA_DIR.glob("steam_*")):
    parts = steam_dir.name.split("_")
    if len(parts) != 3:
        continue
    scan_dir(steam_dir)

if not results:
    print("No v4 format saves found." if not args.json else json.dumps([]))
else:
    by_len = sorted(results, key=lambda x: abs(x[0]) if x[0] != 0 else 0, reverse=True)
    FIELDS = ["catches", "exp", "money", "length", "reel_speed", "string_length", "force"]
    THRESHOLDS = {"catches": 1e6, "exp": 1e7, "money": 1e7, "length": 1e4, "reel_speed": 1e4, "string_length": 1e4, "force": 1e4}
    suspicious = [
        r for r in results
        if any(
            r[3][k] < 0 or r[3][k] > THRESHOLDS[k]
            for k in FIELDS
        )
    ]
    suspicious.sort(key=lambda r: -r[0])

    if args.rename_suspicious:
        for _, _, rel, data, fpath, already in suspicious:
            if already:
                print(f"Skipped {rel} (already renamed)")
                continue
            dst = fpath.with_name(fpath.name[:-4] + ".sus.txt")
            fpath.rename(dst)
            sidecar = fpath.with_name(fpath.name[:-4] + ".sus.json")
            sidecar.write_text(json.dumps(data, indent=2))
            print(f"Renamed {rel} -> {dst.name}")

    if args.json:
        out = {
            "total": len(results),
            "top_by_length": [
                {"length": r[0], "money": r[1], "file": str(r[2])}
                for r in by_len[:20]
            ],
            "suspicious": [
                {"file": str(r[2]), **r[3]}
                for r in suspicious
            ]
        }
        print(json.dumps(out, indent=2))
    else:
        print(f"Found {len(results)} save files.")
        print(f"\n--- Top 20 by |length| ---")
        print(f"{'length':>25} {'money':>25} {'file'}")
        for length, money, rel, _, _, _ in by_len[:20]:
            print(f"{length:>25.2f} {money:>25.2f} {rel}")

        if suspicious:
            print(f"\n--- Suspicious files ---")
            for length, money, rel, data, _, already in suspicious:
                tag = " [already renamed]" if already else ""
                print(f"  length={length:.2f} money={money:.2f} {rel}{tag}")
                for k, v in data.items():
                    print(f"    {k}: {v}")
