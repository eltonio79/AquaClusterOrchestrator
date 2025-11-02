import os, sys, json, uuid, traceback

BASE = os.getenv("ICM_OPT_BASE", os.getcwd())
OUT  = os.getenv("ICM_OUTPUT_DIR", os.path.join(BASE, "data", "output"))
TPL  = os.getenv("ICM_TEMPLATES",  os.path.join(BASE, "data", "input", "templates"))
os.makedirs(OUT, exist_ok=True)

def ok(result): return {"ok": True, "result": result}
def err(msg):   return {"ok": False, "error": msg}

def read_json_stdin():
    buf = sys.stdin.readline()
    if not buf:
        return None
    try:
        return json.loads(buf)
    except Exception as e:
        # Never write logs to stdout; stderr only
        sys.stderr.write(f"mcp_server: invalid JSON on stdin: {e}\n")
        sys.stderr.flush()
        return None

def write_json_stdout(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()

# ------------------- TOOLS IMPLEMENTATION -------------------

def create_file(params):
    path = params.get("path")
    content = params.get("content", "")
    if not path:
        return err("Missing 'path'")
    full = os.path.join(BASE, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as f:
        f.write(content)
    return ok({"path": full})

def write_rul(params):
    name = params.get("name", f"auto_{uuid.uuid4().hex}.rul")
    variables = params.get("variables", {})
    tpl_path = os.path.join(TPL, "rul_template.rul")
    if not os.path.isfile(tpl_path):
        return err(f"Template not found: {tpl_path}")
    with open(tpl_path, "r", encoding="utf-8") as f:
        tpl = f.read()
    for k, v in variables.items():
        tpl = tpl.replace(f"{{{{{k}}}}}", str(v))
    out_path = os.path.join(OUT, name)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(tpl)
    return ok({"path": out_path})

def generate_clusters(params):
    out_path = os.path.join(OUT, f"clusters_{uuid.uuid4().hex}.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump({"clusters": [{"id": 1, "cells": [1, 2, 3]}], "params": params}, f, indent=2)
    return ok({"path": out_path})

def select_areas(params):
    out_path = os.path.join(OUT, f"areas_{uuid.uuid4().hex}.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump({"selection": params}, f, indent=2)
    return ok({"path": out_path})

def run_optimizer(params):
    cfg = params.get("config_path", os.path.join(TPL, "optimization_template.json"))
    if not os.path.isabs(cfg):
        cfg = os.path.join(BASE, cfg)
    if not os.path.isfile(cfg):
        return err(f"Config not found: {cfg}")
    with open(cfg, "r", encoding="utf-8") as f:
        config = json.load(f)
    out_path = os.path.join(OUT, f"optimizer_result_{uuid.uuid4().hex}.json")
    result = {
        "status": "ok",
        "objective": config.get("objective", "n/a"),
        "config": config,
        "result": {"score": 0.87}
    }
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)
    return ok({"path": out_path})

TOOLS = {
    "create_file": create_file,
    "write_rul": write_rul,
    "generate_clusters": generate_clusters,
    "select_areas": select_areas,
    "run_optimizer": run_optimizer,
}

TOOLS_META = {
    "create_file": {
        "name": "create_file",
        "description": "Create a text file relative to BASE with given content.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {"type": "string", "description": "Relative path to create"},
                "content": {"type": "string", "description": "File content"}
            },
            "required": ["path"]
        }
    },
    "write_rul": {
        "name": "write_rul",
        "description": "Render rul_template.rul with variables and write to OUT as .rul.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "name": {"type": "string", "description": "Output file name, .rul"},
                "variables": {"type": "object", "additionalProperties": True}
            }
        }
    },
    "generate_clusters": {
        "name": "generate_clusters",
        "description": "Generate dummy clusters JSON to OUT (demo).",
        "inputSchema": {"type": "object"}
    },
    "select_areas": {
        "name": "select_areas",
        "description": "Persist selection params to OUT (demo).",
        "inputSchema": {"type": "object"}
    },
    "run_optimizer": {
        "name": "run_optimizer",
        "description": "Run mock optimizer using a JSON config file.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "config_path": {"type": "string", "description": "Path to config JSON"}
            }
        }
    }
}

def list_tools_payload():
    return {"tools": [TOOLS_META[name] for name in TOOLS.keys()]}

# ------------------- JSON-RPC HANDLER -------------------

def handle(req):
    try:
        method = req.get("method")
        params = req.get("params", {}) or {}

        # różne inicjalizacje używane przez klientów MCP
        if method in ("server/initialize", "initialize", "mcp/initialize"):
            return ok({
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "icm-tools", "version": "0.1.1"}
            })

        # list tools – obsługujemy stare i nowe nazwy
        if method in ("tools/list", "mcp/listTools"):
            return ok(list_tools_payload())

        # call tool – stare i nowe nazwy
        if method in ("tools/call", "mcp/callTool"):
            name = params.get("name")
            arguments = params.get("arguments", {}) or {}
            if name not in TOOLS:
                return err(f"Unknown tool: {name}")
            return TOOLS[name](arguments)

        # puste listy dla zasobów/prompts/roots żeby UI się nie wywalało
        if method in ("resources/list", "prompts/list", "roots/list"):
            # zwracamy pustą strukturę zgodną z nazwą przestrzeni
            key = method.split('/')[0]
            return ok({key: []})

        return err(f"Unknown method: {method}")
    except Exception as e:
        return err(f"{e}\n{traceback.format_exc()}")

def main():
    while True:
        req = read_json_stdin()
        if req is None:
            break
        req_id = req.get("id", None)
        # Do not respond to notifications (no id) per JSON-RPC
        if req_id is None:
            try:
                handle(req)  # allow side effects if any, but no response
            except Exception as e:
                sys.stderr.write(f"mcp_server: error handling notification: {e}\n")
                sys.stderr.flush()
            continue
        resp = {"id": req_id, "jsonrpc": "2.0"}
        out = handle(req)
        if out.get("ok"):
            resp["result"] = out["result"]
        else:
            resp["error"] = {"code": -32000, "message": out["error"]}
        write_json_stdout(resp)

if __name__ == "__main__":
    main()
