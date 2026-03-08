#!/usr/bin/env python3
"""
check_prerequisites.py — Verify pip packages and Ollama models from settings.yml

Usage:
    python3 make/mantra-db/check_prerequisites.py
    make -f make/mantra-db/Makefile prerequisites
"""

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

try:
    from settings import cfg, all_models
except ImportError as e:
    print(f"[MISSING] pyyaml — run: pip install pyyaml  ({e})")
    sys.exit(1)


def check_pip(packages: list[str]) -> bool:
    ok = True
    for pkg in packages:
        import_name = pkg.replace("-", "_").split("[")[0]  # e.g. pyyaml → pyyaml
        try:
            __import__(import_name)
            print(f"  [OK]      pip: {pkg}")
        except ImportError:
            print(
                f"  [MISSING] pip: {pkg} → run: python3 -m pip install {pkg} --user --break-system-packages"
            )
            ok = False
    return ok


def check_ollama(models: list[str]) -> bool:
    try:
        result = subprocess.run(
            ["ollama", "list"], capture_output=True, text=True, check=True
        )
        available = result.stdout
    except FileNotFoundError:
        print("  [MISSING] ollama — not found in PATH")
        return False
    except subprocess.CalledProcessError as e:
        print(f"  [ERROR]   ollama list failed: {e}")
        return False

    ok = True
    for model in models:
        # ollama list lines look like: "qwen2.5:14b   abc123   1.2 GB   ..."
        if model in available:
            print(f"  [OK]      ollama: {model}")
        else:
            print(f"  [MISSING] ollama: {model}  →  run: ollama pull {model}")
            ok = False
    return ok


def main() -> None:
    c = cfg()
    packages = c.get("python", {}).get("packages", [])
    models = all_models()

    print("── Python packages ──────────────────────────────────")
    pip_ok = check_pip(packages)

    print("── Ollama models ────────────────────────────────────")
    ollama_ok = check_ollama(models)

    print("─────────────────────────────────────────────────────")
    if pip_ok and ollama_ok:
        print("All prerequisites satisfied.")
    else:
        print("Some prerequisites are missing (see above).")
        sys.exit(1)


if __name__ == "__main__":
    main()
