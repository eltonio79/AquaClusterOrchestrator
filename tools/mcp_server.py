import os, sys, json, uuid, traceback

BASE = os.getenv("ICM_OPT_BASE", os.getcwd())
OUT  = os.getenv("ICM_OUTPUT_DIR", os.path.join(BASE, "data", "output"))
TPL  = os.getenv("ICM_TEMPLATES",  os.path.join(BASE, "tools", "templates"))
os.makedirs(OUT, exist_ok=True)

def ok(result): return {"ok": True, "result": result}
def err(msg):   return {"ok": False, "error": msg}

def read_json_stdin():
    buf = sys.stdin.readline()
    if not buf:
        return None
    return json.loads(buf)

def write_json_stdout(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()

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
        json.dump({"clusters": [{"id":1,"cells":[1,2,3]}], "params": params}, f, indent=2)
    return ok({"path": out_path})

def select_areas(params):
    out_path = os.path.join(OUT, f"areas_{uuid.uuid4().hex}.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump({"selection": params}, f, indent=2)
    return ok({"path": out_path})

def run_optimizer(params):
    cfg = params.get("config_path", os.path.join(TPL, "optim_config.json"))
    if not os.path.isabs(cfg):
        cfg = os.path.join(BASE, cfg)
    if not os.path.isfile(cfg):
        return err(f"Config not found: {cfg}")
    with open(cfg, "r", encoding="utf-8") as f:
        config = json.load(f)
    out_path = os.path.join(OUT, f"optimizer_result_{uuid.uuid4().hex}.json")
    result = {"status":"ok","objective":config.get("objective","n/a"),"config":config,"result":{"score":0.87}}
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

def handle(req):
    try:
        method = req.get("method")
        if method in ("mcp/initialize", "mcp/listTools"):
            return ok({"tools": list(TOOLS.keys())})
        if method == "mcp/callTool":
            name = req.get("params",{}).get("name")
            params = req.get("params",{}).get("arguments",{}) or {}
            if name not in TOOLS:
                return err(f"Unknown tool: {name}")
            return TOOLS[name](params)
        return err(f"Unknown method: {method}")
    except Exception as e:
        return err(f"{e}\n{traceback.format_exc()}")

def main():
    while True:
        req = read_json_stdin()
        if req is None:
            break
        resp = {"id": req.get("id"), "jsonrpc":"2.0"}
        out = handle(req)
        if out.get("ok"):
            resp["result"] = out["result"]
        else:
            resp["error"] = {"code": -32000, "message": out["error"]}
        write_json_stdout(resp)

if __name__ == "__main__":
    main()
