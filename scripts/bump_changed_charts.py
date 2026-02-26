#!/usr/bin/env python3
"""Bump Helm chart versions for charts with local changes."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Iterable

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
CHARTS_DIR = REPO_ROOT / "charts"

sys.path.insert(0, str(SCRIPT_DIR))
from bump_chart_versions import bump_chart_version  # noqa: E402


def run_git_status() -> list[str]:
    rel_charts = CHARTS_DIR.relative_to(REPO_ROOT)
    cmd = [
        "git",
        "-C",
        str(REPO_ROOT),
        "status",
        "--porcelain",
        "--untracked-files=normal",
        str(rel_charts),
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        print(proc.stderr.strip() or "Failed to run git status", file=sys.stderr)
        raise SystemExit(proc.returncode)
    return proc.stdout.splitlines()


def extract_chart_dirs(lines: Iterable[str]) -> list[Path]:
    rel_charts = CHARTS_DIR.relative_to(REPO_ROOT)
    rel_parts = rel_charts.parts
    chart_dirs: set[Path] = set()
    for raw in lines:
        if len(raw) < 4:
            continue
        path_spec = raw[3:]
        if " -> " in path_spec:
            path_spec = path_spec.split(" -> ", 1)[1]
        rel_path = Path(path_spec.rstrip("/"))
        if len(rel_path.parts) <= len(rel_parts):
            continue
        if tuple(rel_path.parts[: len(rel_parts)]) != rel_parts:
            continue
        target = CHARTS_DIR.joinpath(*rel_path.parts[len(rel_parts) : len(rel_parts) + 1])
        if target.is_dir():
            chart_dirs.add(target)
    return sorted(chart_dirs)


def main() -> int:
    if not CHARTS_DIR.is_dir():
        print(f"Charts directory {CHARTS_DIR} not found", file=sys.stderr)
        return 1

    status_lines = run_git_status()
    targets = extract_chart_dirs(status_lines)
    if not targets:
        print("No modified charts detected.")
        return 0

    bumped = 0
    for chart_dir in targets:
        chart_name = chart_dir.name
        try:
            old, new = bump_chart_version(chart_dir)
        except Exception as exc:  # noqa: BLE001
            print(f"[ERROR] {chart_name}: {exc}", file=sys.stderr)
            continue
        print(f"[OK] {chart_name}: {old} -> {new}")
        bumped += 1

    if bumped == 0:
        print("No chart versions updated", file=sys.stderr)
        return 1
    print(f"Updated {bumped} chart versions.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
