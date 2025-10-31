#!/usr/bin/env python3
"""
Processed Results Tracker

Maintains a JSON registry of processed simulations for the current project.
File: data/output/processed_results.json
"""

from __future__ import annotations
import os, json, time
from typing import Any, Dict, List, Optional


def _paths(base: Optional[str] = None) -> Dict[str, str]:
    base_dir = base or os.path.join(os.getcwd(), "data", "output")
    os.makedirs(base_dir, exist_ok=True)
    return {
        "base": base_dir,
        "file": os.path.join(base_dir, "processed_results.json"),
    }


def _load(path: str) -> Dict[str, Any]:
    if not os.path.exists(path):
        return {"items": []}
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {"items": []}


def _save(path: str, data: Dict[str, Any]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)


def mark_as_processed(database_path: str, sim_id: int, sim_name: str, out_dir: str,
                      rules: Optional[List[str]] = None, status: str = "complete",
                      base: Optional[str] = None) -> Dict[str, Any]:
    p = _paths(base)
    data = _load(p["file"])
    item = {
        "database": os.path.abspath(database_path),
        "simulation_id": int(sim_id),
        "simulation_name": sim_name,
        "output_dir": os.path.abspath(out_dir),
        "rules": rules or [],
        "status": status,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S")
    }
    # replace if exists
    rest = [x for x in data["items"] if not (x.get("database") == item["database"] and x.get("simulation_id") == item["simulation_id"]) ]
    data["items"] = rest + [item]
    _save(p["file"], data)
    return item


def list_processed(database_path: Optional[str] = None, base: Optional[str] = None) -> List[Dict[str, Any]]:
    p = _paths(base)
    data = _load(p["file"])
    items = data.get("items", [])
    if database_path:
        db = os.path.abspath(database_path)
        items = [x for x in items if x.get("database") == db]
    return items


def is_processed(database_path: str, sim_id: int, base: Optional[str] = None) -> bool:
    items = list_processed(database_path, base)
    return any(x for x in items if x.get("simulation_id") == int(sim_id))


def get_processed(database_path: str, sim_id: int, base: Optional[str] = None) -> Optional[Dict[str, Any]]:
    items = list_processed(database_path, base)
    for x in items:
        if x.get("simulation_id") == int(sim_id):
            return x
    return None


if __name__ == "__main__":
    # basic smoke test
    base_dir = os.path.join(os.getcwd(), "data", "output")
    item = mark_as_processed("models/standalone/Medium 2D/Ruby_Hackathon_Medium_2D_Model.icmm", 1, "Demo Sim", os.path.join(base_dir, "rasters", "sim_1"))
    print("Recorded:", item)
    print("List:", list_processed())


