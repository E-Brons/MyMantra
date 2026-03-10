#!/usr/bin/env python3
"""
translate_n_dedup.py — Translate, deduplicate, and produce multi-language mantra index.

Pipeline (all LLM calls sequential to avoid Ollama model-swapping):

  Step 1: Translate every phrase to English (normalise across scripts).
  Step 2: Dedup by English form (case-insensitive + phrase_aliases.json).
  Step 3: Transliterate each unique mantra.
  Step 4: Translate each unique mantra into all target languages.

All tasks, models, and options are driven by settings.yml under translate_n_dedup.
Output: tmp/mantra_index_deduped.json  (resumable at each step)
"""

import asyncio
import json
import re
import sys
import time
from collections import defaultdict
from pathlib import Path

import litellm
from tqdm import tqdm

sys.path.insert(0, str(Path(__file__).parent))
from settings import root_path, cfg, ollama

litellm.set_verbose = False

_ROOT = Path(__file__).parent.parent.parent
_dcfg = cfg()["translate_n_dedup"]

INPUT = root_path("translate_n_dedup", "input")
OUTPUT = root_path("translate_n_dedup", "output")
ALIASES = Path(__file__).parent / _dcfg["aliases"]

# Intermediate caches (resumable)
ENGLISH_CACHE = _ROOT / "tmp" / "mantra_english_cache.json"
TRANSLIT_CACHE = _ROOT / "tmp" / "mantra_translit_cache.json"

# ── config from settings.yml ─────────────────────────────────────────────────
SYSTEM_PROMPT = _dcfg["system"].strip()

# Params that litellm accepts directly (rest go to extra_body.options for Ollama)
_LITELLM_PARAMS = {"temperature", "top_p", "max_tokens", "stop", "seed"}


def _build_kwargs(opts: dict) -> tuple[dict, int]:
    """Build litellm kwargs + timeout from an llm_options dict."""
    kwargs: dict = {}
    ollama_opts: dict = {}
    timeout = 90
    for k, v in opts.items():
        if k == "timeout":
            timeout = int(v)
        elif k in _LITELLM_PARAMS:
            kwargs[k] = v
        else:
            ollama_opts[k] = v
    if ollama_opts:
        kwargs["extra_body"] = {"options": ollama_opts}
    return kwargs, timeout


_eng_cfg = _dcfg["english"]
MODEL_ENGLISH = ollama(_eng_cfg["llm_engine"])
ENGLISH_KWARGS, ENGLISH_TIMEOUT = _build_kwargs(_eng_cfg.get("llm_options", {}))
ENGLISH_TASK = _eng_cfg["task"].strip()

_prof_cfg = _dcfg["filter"]
MODEL_PROFILER = ollama(_prof_cfg["llm_engine"])
PROFILER_KWARGS, PROFILER_TIMEOUT = _build_kwargs(_prof_cfg.get("llm_options", {}))
PROFILER_TASK = _prof_cfg["task"].strip()

_tlit_cfg = _dcfg["transliteration"]
MODEL_TRANSLIT = ollama(_tlit_cfg["llm_engine"])
TRANSLIT_KWARGS, TRANSLIT_TIMEOUT = _build_kwargs(_tlit_cfg.get("llm_options", {}))
TRANSLIT_TASK = _tlit_cfg["task"].strip()

_trans_cfg = _dcfg["translations"]
MODEL_TRANSLATOR = ollama(_trans_cfg["llm_engine"])
TRANSLATOR_KWARGS, TRANSLATOR_TIMEOUT = _build_kwargs(_trans_cfg.get("llm_options", {}))
_lang_cfg = _trans_cfg["languages"]
TRANSLATE_TASK = _lang_cfg["task"].strip()
TRANSLATE_LANGUAGES: dict[str, str] = {
    k: v for k, v in _lang_cfg.items() if k != "task"
}

_SEP = "#" * 79


def _banner(title: str, body_lines: list) -> None:
    print(_SEP)
    print(f"### {title}")
    print(_SEP)
    for line in body_lines:
        print(line)
    print(_SEP)


def _parse_answer(raw: str) -> str:
    """Extract the Answer portion from 'Answer: ... Grounding: ...' format."""
    answer_match = re.search(r"(?i)^answer:\s*", raw, re.MULTILINE)
    grounding_match = re.search(r"(?i)^grounding:\s*", raw, re.MULTILINE)
    if (
        answer_match
        and grounding_match
        and grounding_match.start() > answer_match.start()
    ):
        return raw[answer_match.end() : grounding_match.start()].strip()
    if answer_match:
        return raw[answer_match.end() :].strip()
    return raw.strip()


# ─────────────────────────────────────────────────────────────────────────────
# Generic LLM call (used by all steps)
# ─────────────────────────────────────────────────────────────────────────────


async def _call_llm(model: str, system: str, user: str, timeout: int, **kwargs) -> str:
    """Single LLM call. Returns parsed answer (grounding stripped)."""
    response = await litellm.acompletion(
        model=model,
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        timeout=timeout,
        **kwargs,
    )
    raw = (response.choices[0].message.content or "").strip()
    return _parse_answer(raw)


# ─────────────────────────────────────────────────────────────────────────────
# Filtering: heuristic pre-filter + LLM profiler
# ─────────────────────────────────────────────────────────────────────────────


def _is_obviously_not_mantra(phrase: str) -> bool:
    """Quick heuristic pre-filter. Returns True for obvious non-mantras."""
    lower = phrase.lower().strip()
    words = lower.split()

    # Too long — mantras are short phrases, not paragraphs
    if len(phrase) > 200:
        return True
    # Too many words
    if len(words) > 25:
        return True
    # Multiple sentences (period/exclamation/question followed by uppercase or non-Latin)
    if re.search(r"[.!?]\s+[A-Z\u0400-\u04ff\u0600-\u06ff\u0900-\u097f]", phrase):
        return True
    # Bare word "mantra" (with optional article/plural) or dictionary-style "mantra (noun)"
    if re.fullmatch(r"(a\s+|the\s+)?mantras?(\s*\(.*\))?", lower):
        return True
    # Numbered titles like "Hanuman Gayatri Mantra 108 times"
    if re.search(r"\d+\s+times\b", lower):
        return True
    # Encyclopedic sentences: contains "is a", "are a", "is the", "refers to", etc.
    if re.search(
        r"\b(is\s+(a|an|the|considered|defined|known)|are\s+(a|the|considered|sacred)"
        r"|refers?\s+to|defined\s+as|meaning\s+of)\b",
        lower,
    ):
        return True
    # List/article titles: "Top N ...", "Best ... mantras", "List of ..."
    if re.search(r"^(top\s+\d+|best\s+|list\s+of\s+|types?\s+of\s+)", lower):
        return True
    return False


async def _profile_is_mantra(english: str) -> bool:
    """LLM profiler: classifies the English translation using multi-category prompt.
    Returns True only if the model answers 'true'."""
    try:
        result = await _call_llm(
            MODEL_PROFILER,
            PROFILER_TASK,
            f"Text: {english}",
            PROFILER_TIMEOUT,
            **PROFILER_KWARGS,
        )
        return result.strip().lower() == "true"
    except Exception:
        return True  # on failure, keep it (conservative)


# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Translate to English
# ─────────────────────────────────────────────────────────────────────────────


_NOT_A_MANTRA_SUFFIX = """

If the text is NOT a mantra (e.g. a description, sentence, dictionary entry, \
or grammar term), return exactly: NOT_A_MANTRA"""


async def translate_to_english(phrase: str, language: str) -> str:
    """Translate a single phrase to English. Returns English form or 'NOT_A_MANTRA'."""
    system = SYSTEM_PROMPT.replace("{source language}", language).replace(
        "{target language}", "English (USA)"
    )
    task = ENGLISH_TASK + _NOT_A_MANTRA_SUFFIX
    user = f"Language: {language}\nPhrase: {phrase}\n\n--- Task ---\n{task}"
    try:
        result = await _call_llm(
            MODEL_ENGLISH, system, user, ENGLISH_TIMEOUT, **ENGLISH_KWARGS
        )
        # Clean up: remove quotes, markdown, etc.
        result = result.strip("\"'`").strip()
        if result.startswith("```"):
            result = result.split("\n")[1] if "\n" in result else result
        return result if result else "NOT_A_MANTRA"
    except Exception:
        return "NOT_A_MANTRA"  # on failure, filter it out


async def step1_translate_all(entries: list[dict]) -> dict[str, str]:
    """Translate all phrases to English.
    Returns {original_phrase: english_form_or_NOT_A_MANTRA}.
    Resumes from ENGLISH_CACHE if it exists."""
    cache: dict[str, str] = {}
    if ENGLISH_CACHE.exists():
        cache = json.loads(ENGLISH_CACHE.read_text())
        print(f"  Resuming: {len(cache)} phrases in cache.")

    remaining = [e for e in entries if e["phrase"] not in cache]
    if not remaining:
        print(f"  All {len(cache)} phrases already translated.")
        return cache

    with tqdm(
        total=len(entries), initial=len(cache), desc="  Translating", unit="phrase"
    ) as pbar:
        for entry in remaining:
            phrase = entry["phrase"]
            language = entry.get("language", "Unknown")
            pbar.set_postfix_str(f"'{phrase[:35]}'")

            if _is_obviously_not_mantra(phrase):
                cache[phrase] = "NOT_A_MANTRA"
            else:
                english = await translate_to_english(phrase, language)
                cache[phrase] = english

            ENGLISH_CACHE.write_text(json.dumps(cache, indent=2, ensure_ascii=False))
            pbar.update(1)

    return cache


# ─────────────────────────────────────────────────────────────────────────────
# Step 2: Filter non-mantras (heuristic + LLM profiler)
# ─────────────────────────────────────────────────────────────────────────────

# Marker prefix for entries that passed the profiler (avoids re-profiling on resume)
_PROFILED_OK = "_OK_"


async def step2_filter(english_map: dict[str, str]) -> dict[str, str]:
    """Run the LLM profiler on all translated phrases that haven't been filtered yet.
    Modifies english_map in place and saves to ENGLISH_CACHE. Returns the same map."""

    # Build work list: entries that are not yet profiled and not already filtered
    to_profile = [
        (phrase, english)
        for phrase, english in english_map.items()
        if english != "NOT_A_MANTRA" and not english.startswith(_PROFILED_OK)
    ]

    if not to_profile:
        already_ok = sum(1 for v in english_map.values() if v.startswith(_PROFILED_OK))
        print(f"  All {already_ok} phrases already profiled.")
        return english_map

    filtered = 0
    with tqdm(total=len(to_profile), desc="  Filtering", unit="phrase") as pbar:
        for phrase, english in to_profile:
            pbar.set_postfix_str(f"'{english[:35]}'")

            is_mantra = await _profile_is_mantra(english)
            if is_mantra:
                english_map[phrase] = _PROFILED_OK + english
            else:
                english_map[phrase] = "NOT_A_MANTRA"
                filtered += 1

            ENGLISH_CACHE.write_text(
                json.dumps(english_map, indent=2, ensure_ascii=False)
            )
            pbar.update(1)

    print(f"  Filtered {filtered}/{len(to_profile)} phrases as not-a-mantra.")
    return english_map


def _strip_profiled_prefix(english_map: dict[str, str]) -> dict[str, str]:
    """Strip the _OK_ prefix from profiled entries for downstream consumption."""
    return {
        phrase: (english.removeprefix(_PROFILED_OK) if english != "NOT_A_MANTRA" else english)
        for phrase, english in english_map.items()
    }


# ─────────────────────────────────────────────────────────────────────────────
# Step 3: Dedup
# ─────────────────────────────────────────────────────────────────────────────


def load_aliases() -> tuple[list[tuple[str, str]], dict[str, str]]:
    if not ALIASES.exists():
        return [], {}
    data = json.loads(ALIASES.read_text())
    prefix_rules: list[tuple[str, str]] = [
        tuple(r) for r in data.get("prefix_rules", [])
    ]
    exact_rules: dict[str, str] = data.get("exact_rules", {})
    return prefix_rules, exact_rules


def canonicalize(
    phrase: str, prefix_rules: list[tuple[str, str]], exact_rules: dict[str, str]
) -> str:
    """Return the canonical form of a phrase per alias rules."""
    if phrase in exact_rules:
        return exact_rules[phrase]
    for prefix, replacement in prefix_rules:
        if phrase.startswith(prefix):
            return replacement + phrase[len(prefix) :]
    return phrase


def step3_dedup(entries: list[dict], english_map: dict[str, str]) -> dict[str, dict]:
    """Dedup entries by English form. Returns {canonical_english: merged_record}."""
    prefix_rules, exact_rules = load_aliases()

    # Filter out non-mantras
    filtered = []
    not_mantra_count = 0
    for e in entries:
        english = english_map.get(e["phrase"], e["phrase"])
        if english == "NOT_A_MANTRA":
            not_mantra_count += 1
            continue
        filtered.append({**e, "_english": english})

    if not_mantra_count:
        print(f"  Filtered out {not_mantra_count} non-mantra entries.")

    # Group by canonical English form
    groups: dict[str, list[dict]] = defaultdict(list)
    canonical_for_key: dict[str, str] = {}

    for entry in filtered:
        english = entry["_english"]
        canonical = canonicalize(english, prefix_rules, exact_rules)
        key = canonical.lower().strip()

        if key not in canonical_for_key:
            canonical_for_key[key] = canonical

        groups[key].append(
            {
                **entry,
                "_canonical": canonical_for_key[key],
            }
        )

    # Merge each group
    deduped: dict[str, dict] = {}
    for key, group_entries in groups.items():
        phrase = group_entries[0]["_canonical"]

        languages = list(
            dict.fromkeys(
                e.get("language", "").strip()
                for e in group_entries
                if e.get("language")
            )
        )
        tags = list(
            dict.fromkeys(tag for e in group_entries for tag in e.get("tags", []))
        )

        # Collect all original phrases (for reference)
        original_phrases = list(
            dict.fromkeys(e["phrase"] for e in group_entries if e["phrase"] != phrase)
        )

        # Deduplicate sources by URL
        seen_urls: set[str] = set()
        sources: list[dict] = []
        for e in group_entries:
            url = e.get("source_url", "").strip()
            if url and url not in seen_urls:
                seen_urls.add(url)
                source: dict = {
                    "url": url,
                    "title": e.get("source_title", "").strip(),
                    "fetched_at": e.get("fetched_at", ""),
                }
                if e["phrase"] != phrase:
                    source["original_phrase"] = e["phrase"]
                sources.append(source)

        record = {
            "phrase": phrase,
            "language": languages,
            "tags": tags,
            "sources": sources,
        }
        if original_phrases:
            record["original_phrases"] = original_phrases

        deduped[phrase] = record

    return deduped


# ─────────────────────────────────────────────────────────────────────────────
# Step 4: Transliterate
# ─────────────────────────────────────────────────────────────────────────────


async def transliterate(phrase: str, language: str) -> str:
    """Transliterate a mantra to romanised form with diacritics."""
    system = SYSTEM_PROMPT.replace("{source language}", language).replace(
        "{target language}", "romanised transliteration"
    )
    user = f"Language: {language}\nPhrase: {phrase}\n\n--- Task ---\n{TRANSLIT_TASK}"
    try:
        return await _call_llm(
            MODEL_TRANSLIT, system, user, TRANSLIT_TIMEOUT, **TRANSLIT_KWARGS
        )
    except Exception:
        return phrase


async def step4_transliterate_all(deduped: dict[str, dict]) -> None:
    """Add transliteration to all entries. Modifies in place, saves after each."""
    cache: dict[str, str] = {}
    if TRANSLIT_CACHE.exists():
        cache = json.loads(TRANSLIT_CACHE.read_text())

    to_do = [
        p for p in deduped if "transliteration" not in deduped[p] and p not in cache
    ]
    # Apply cached values first
    for phrase, translit in cache.items():
        if phrase in deduped and "transliteration" not in deduped[phrase]:
            deduped[phrase]["transliteration"] = translit

    if not to_do:
        print(f"  All {len(deduped)} entries already transliterated.")
        return

    print(f"  Transliterating {len(to_do)} entries with {MODEL_TRANSLIT}")
    with tqdm(total=len(to_do), desc="  Transliterating", unit="mantra") as pbar:
        for phrase in to_do:
            pbar.set_postfix_str(f"'{phrase[:35]}'")
            entry = deduped[phrase]
            lang = (
                entry.get("language", ["Unknown"])[0]
                if entry.get("language")
                else "Unknown"
            )

            translit = await transliterate(phrase, lang)
            entry["transliteration"] = translit
            cache[phrase] = translit

            TRANSLIT_CACHE.write_text(json.dumps(cache, indent=2, ensure_ascii=False))
            OUTPUT.write_text(json.dumps(deduped, indent=2, ensure_ascii=False))
            pbar.update(1)


# ─────────────────────────────────────────────────────────────────────────────
# Step 5: Full translation batch
# ─────────────────────────────────────────────────────────────────────────────


async def translate_one(
    phrase: str, source_lang: str, target_code: str, target_name: str
) -> str:
    """Translate one mantra into one target language."""
    system = SYSTEM_PROMPT.replace("{source language}", source_lang).replace(
        "{target language}", target_name
    )
    task = TRANSLATE_TASK.replace("{target language}", target_name)
    user = f"Language: {source_lang}\nPhrase: {phrase}\n\n--- Task ---\n{task}"
    try:
        return await _call_llm(
            MODEL_TRANSLATOR, system, user, TRANSLATOR_TIMEOUT, **TRANSLATOR_KWARGS
        )
    except Exception:
        return ""


async def step5_translate_all(deduped: dict[str, dict]) -> None:
    """Add translations to all deduped entries. Modifies in place, saves after each."""
    # Build work list: (phrase, code, name) for each missing translation
    work: list[tuple[str, str, str]] = []
    for phrase, entry in deduped.items():
        existing = entry.get("translations", {})
        for code, name in TRANSLATE_LANGUAGES.items():
            if not existing.get(code):
                work.append((phrase, code, name))

    if not work:
        print(f"  All {len(deduped)} entries already translated.")
        return

    mantras_left = len({w[0] for w in work})
    print(
        f"  {mantras_left} mantras, {len(work)} translations remaining with {MODEL_TRANSLATOR}"
    )

    with tqdm(total=len(work), desc="  Translating", unit="call") as pbar:
        current_phrase = ""
        for phrase, code, name in work:
            if phrase != current_phrase:
                current_phrase = phrase
                pbar.set_postfix_str(f"'{phrase[:25]}' → {name}")
            else:
                pbar.set_postfix_str(f"'{phrase[:25]}' → {name}")

            entry = deduped[phrase]
            lang = (
                entry.get("language", ["Unknown"])[0]
                if entry.get("language")
                else "Unknown"
            )
            translations = entry.setdefault("translations", {})

            result = await translate_one(phrase, lang, code, name)
            if result:
                translations[code] = result
            pbar.update(1)

            # Check if this mantra is now complete — save and update supportedLanguages
            remaining_for_phrase = [
                c for c, n in TRANSLATE_LANGUAGES.items() if not translations.get(c)
            ]
            if not remaining_for_phrase:
                entry["supportedLanguages"] = [
                    k for k in TRANSLATE_LANGUAGES if translations.get(k)
                ]
                OUTPUT.write_text(json.dumps(deduped, indent=2, ensure_ascii=False))


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────


async def main() -> None:
    data = json.loads(INPUT.read_text())
    raw: list[dict] = data.get("mantras", data) if isinstance(data, dict) else data

    _banner(
        "Stage 3: translate_n_dedup",
        [
            f"###   Input:            {INPUT}  ({len(raw)} entries)",
            f"###   Output:           {OUTPUT}",
            f"###   Aliases:          {ALIASES}",
            f"###   English model:    {MODEL_ENGLISH}",
            f"###   Profiler model:   {MODEL_PROFILER}",
            f"###   Translit model:   {MODEL_TRANSLIT}",
            f"###   Translator model: {MODEL_TRANSLATOR}",
            f"###   Languages:        {len(TRANSLATE_LANGUAGES)}",
        ],
    )
    print()

    # ── Step 1: Translate to English ────────────────────────────────────────
    print("Step 1/5 — Translate to English")
    english_map = await step1_translate_all(raw)

    translated = sum(1 for v in english_map.values() if v != "NOT_A_MANTRA")
    heuristic_filtered = sum(1 for v in english_map.values() if v == "NOT_A_MANTRA")
    print(
        f"  Done: {len(english_map)} processed, {translated} translated,"
        f" {heuristic_filtered} filtered by heuristic/translator.\n"
    )

    # ── Step 2: Filter non-mantras (LLM profiler) ────────────────────────
    print("Step 2/5 — Filter non-mantras")
    english_map = await step2_filter(english_map)

    not_mantra = sum(1 for v in english_map.values() if v == "NOT_A_MANTRA")
    english_map = _strip_profiled_prefix(english_map)
    print(
        f"  Done: {not_mantra} total non-mantras filtered.\n"
    )

    # ── Step 3: Dedup ────────────────────────────────────────────────────────
    print("Step 3/5 — Dedup by English form + aliases")
    deduped = step3_dedup(raw, english_map)
    print(
        f"  Done: {len(raw)} entries → {len(deduped)} unique mantras "
        f"({len(raw) - len(deduped) - not_mantra} duplicates, {not_mantra} filtered).\n"
    )

    # Write deduped (without translations yet) so subsequent steps can resume
    OUTPUT.write_text(json.dumps(deduped, indent=2, ensure_ascii=False))

    # ── Step 4: Transliterate ────────────────────────────────────────────────
    print("Step 4/5 — Transliterate all phrases")
    await step4_transliterate_all(deduped)
    print()

    # ── Step 5: Full translation batch ───────────────────────────────────────
    print("Step 5/5 — Full multi-language translation")
    await step5_translate_all(deduped)
    print()

    # ── Results ──────────────────────────────────────────────────────────────
    translated = sum(1 for e in deduped.values() if "translations" in e)
    transliterated = sum(1 for e in deduped.values() if "transliteration" in e)
    _banner(
        "Results: translate_n_dedup",
        [
            f"###   Input:          {len(raw)} entries",
            f"###   Output:         {len(deduped)} unique mantras",
            f"###   Transliterated: {transliterated}/{len(deduped)}",
            f"###   Translated:     {translated}/{len(deduped)}",
            f"###   Filtered:       {not_mantra} non-mantra entries",
            f"###   Written:        {OUTPUT}",
        ],
    )


if __name__ == "__main__":
    asyncio.run(main())
