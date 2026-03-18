"""
Logging infrastructure for the mantra-db pipeline.

Two destinations, independently configurable:
  - File:   tmp/mantra-db/log_YYYY_MM_DD.txt  (DEBUG and up)
  - Screen: stdout via tqdm.write()            (INFO  and up)

Usage in any pipeline script:
    from log import get_logger
    log = get_logger("stage_name")

    log.info("current status")           # -> screen + file
    log.debug("LLM prompt: %s", prompt)  # -> file only
    log.warning("fetch failed: %s", url) # -> screen + file
"""

import logging
import time
from datetime import date
from pathlib import Path

from tqdm import tqdm

_ROOT = Path(__file__).parent.parent.parent  # make/mantra-db -> make -> project root
_LOG_DIR = _ROOT / "tmp" / "mantra-db"

_configured = False


class _TqdmHandler(logging.StreamHandler):
    """StreamHandler that uses tqdm.write() to avoid breaking progress bars."""

    def emit(self, record):
        try:
            msg = self.format(record)
            tqdm.write(msg)
        except Exception:
            self.handleError(record)


def setup(
    *,
    file_level: int = logging.DEBUG,
    console_level: int = logging.INFO,
) -> None:
    """Configure the mantra_db root logger (idempotent).

    Args:
        file_level:    minimum level written to the log file  (default DEBUG).
        console_level: minimum level written to the screen    (default INFO).
    """
    global _configured
    if _configured:
        return
    _configured = True

    _LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_file = _LOG_DIR / f"log_{date.today().strftime('%Y_%m_%d')}.txt"

    root = logging.getLogger("mantra_db")
    root.setLevel(logging.DEBUG)  # allow everything; handlers filter

    # ── File handler (DEBUG+) ────────────────────────────────────────────────
    fh = logging.FileHandler(log_file, encoding="utf-8")
    fh.setLevel(file_level)
    fh.setFormatter(logging.Formatter(
        "%(asctime)s  %(levelname)-7s  %(name)s  %(message)s",
        datefmt="%H:%M:%S",
    ))
    root.addHandler(fh)

    # ── Console handler (INFO+, tqdm-compatible) ─────────────────────────────
    ch = _TqdmHandler()
    ch.setLevel(console_level)
    ch.setFormatter(logging.Formatter("%(message)s"))
    root.addHandler(ch)


def get_logger(name: str) -> logging.Logger:
    """Return a child logger under the mantra_db namespace.

    Automatically calls setup() on first use.
    """
    setup()
    return logging.getLogger(f"mantra_db.{name}")


# ── Timing helper ────────────────────────────────────────────────────────────


class Timer:
    """Simple context-manager / manual timer for performance metrics.

    Usage:
        with Timer() as t:
            do_work()
        log.info("took %.1fs", t.elapsed)

    Or manually:
        t = Timer().start()
        ...
        t.stop()
        log.info("took %.1fs", t.elapsed)
    """

    def __init__(self):
        self._t0: float = 0.0
        self._t1: float = 0.0

    @property
    def elapsed(self) -> float:
        if self._t1:
            return self._t1 - self._t0
        return time.perf_counter() - self._t0

    def start(self) -> "Timer":
        self._t0 = time.perf_counter()
        return self

    def stop(self) -> float:
        self._t1 = time.perf_counter()
        return self.elapsed

    def __enter__(self) -> "Timer":
        self.start()
        return self

    def __exit__(self, *_):
        self.stop()
