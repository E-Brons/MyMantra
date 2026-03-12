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

from log import get_logger
_log = get_logger("prerequisites")


def check_pip(packages: list[str]) -> bool:
    ok = True
    for pkg in packages:
        import_name = pkg.replace("-", "_").split("[")[0]  # e.g. pyyaml → pyyaml
        try:
            __import__(import_name)
            _log.info("  [OK]      pip: %s", pkg)
        except ImportError:
            _log.warning(
                "  [MISSING] pip: %s → run: python3 -m pip install %s --user --break-system-packages",
                pkg, pkg,
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
        _log.warning("  [MISSING] ollama — not found in PATH")
        return False
    except subprocess.CalledProcessError as e:
        _log.warning("  [ERROR]   ollama list failed: %s", e)
        return False

    ok = True
    for model in models:
        # ollama list lines look like: "qwen2.5:14b   abc123   1.2 GB   ..."
        if model in available:
            _log.info("  [OK]      ollama: %s", model)
        else:
            _log.warning("  [MISSING] ollama: %s  →  run: ollama pull %s", model, model)
            ok = False
    return ok


def main() -> None:
    c = cfg()
    packages = c.get("python", {}).get("packages", [])
    models = all_models()

    _log.info("── Python packages ──────────────────────────────────")
    pip_ok = check_pip(packages)

    _log.info("── Ollama models ────────────────────────────────────")
    ollama_ok = check_ollama(models)

    _log.info("─────────────────────────────────────────────────────")
    if pip_ok and ollama_ok:
        _log.info("All prerequisites satisfied.")
    else:
        _log.warning("Some prerequisites are missing (see above).")
        sys.exit(1)


if __name__ == "__main__":
    main()
