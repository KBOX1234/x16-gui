import json
import os

PROJECT_ROOT = os.getcwd()

sources = []

for root, dirs, files in os.walk("."):
    # Don't scan generated files
    dirs[:] = [
        d for d in dirs
        if d not in ("build", ".git")
    ]

    for f in files:
        if f.endswith(".c"):
            sources.append(os.path.join(root, f).lstrip("./"))

commands = []

for src in sources:
    abs_src = os.path.join(PROJECT_ROOT, src)

    commands.append({
        "directory": PROJECT_ROOT,
        "file": abs_src,
        "command": (
            f"clang "
            f"-D__CC65__ "
            f"-D__CX16__ "
            f"-D__CPU_65C02__ "
            f"-std=c89 "
            f"-I{PROJECT_ROOT}/include "
            f"-I/usr/share/cc65/include "
            f"-c {abs_src} "
            f"-o /tmp/{os.path.basename(src)}.o"
        )
    })

with open("compile_commands.json", "w") as f:
    json.dump(commands, f, indent=2)
