#!/usr/bin/env python3
"""
For every deduped mantra in scripts/mantra_index_deduped.json:
  1. Find a matching entry in assets/data/mantras/*.json (if any)
  2. Fetch up to 2 source URLs for context / abstract validation
  3. Draft with every engine in llm_engines (in parallel, any number of models)
     each model may call the web_search tool for additional context
  4. Merge all drafts with llm_combine
  5. Grade each student draft: llm_grader fires one async call per category,
     Python applies YAML weights → score 0-100 (single standard, consistent rubric)
  6. Write to scripts/enriched_mantras.json  (resumable — skips already-done)
  7. Scatter-plot all scores at the end (one series per engine)

Progress: tqdm bar with per-mantra phrase postfix; student models run concurrently
via asyncio.gather; URL fetching via asyncio.to_thread.
"""

import asyncio
import json
import re
import sys
import time
from pathlib import Path

import requests
import litellm
from ddgs import DDGS
from tqdm import tqdm

sys.path.insert(0, str(Path(__file__).parent))
from settings import root_path, cfg, ollama, llm_kwargs, parse_fenced_json

litellm.set_verbose = False  # suppress request-level noise

_ROOT = Path(__file__).parent.parent.parent  # make/mantra-db -> make -> project root
DEDUPED = root_path("enrich_mantras", "input")
MANTRAS_FILE = _ROOT / "assets" / "data" / "mantras.json"
OUTPUT = root_path("enrich_mantras", "output")

# ── models ────────────────────────────────────────────────────────────────────
_engines = cfg()["enrich_mantras"]["llm_engines"]  # list of N student engines
STUDENT_MODELS = [ollama(e) for e in _engines]  # any length ≥ 1
MODEL_MERGE = ollama(cfg()["enrich_mantras"]["llm_combine"])
MODEL_GRADER = ollama(cfg()["enrich_mantras"]["llm_grader"])
MODEL_TRANSLATOR = ollama(cfg()["enrich_mantras"]["translator_llm"])
LLM_KWARGS = llm_kwargs("enrich_mantras")              # students + merge
GRADER_KWARGS = llm_kwargs("enrich_mantras", "grader_options")
TRANSLATOR_KWARGS = llm_kwargs("enrich_mantras", "translator_options")

_SEP = "#" * 79


def _banner(title: str, body_lines: list) -> None:
    print(_SEP)
    print(f"### {title}")
    print(_SEP)
    for line in body_lines:
        print(line)
    print(_SEP)

# ── tuning ────────────────────────────────────────────────────────────────────
MAX_SOURCE_CHARS = int(cfg()["enrich_mantras"]["max_source_chars"])
HTTP_TIMEOUT = int(cfg()["enrich_mantras"]["http_timeout"])

# ── grading weights (from yaml, with safe defaults) ───────────────────────────
_grade_cfg = cfg()["enrich_mantras"].get("grade", {})


# ─────────────────────────────────────────────────────────────────────────────
# Web search tool  (DuckDuckGo — no API key needed)
# ─────────────────────────────────────────────────────────────────────────────

_SEARCH_TOOL_DEF = {
    "type": "function",
    "function": {
        "name": "web_search",
        "description": (
            "Search the web for information about a mantra, its tradition, "
            "meaning, or historical context. Use this to improve accuracy."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "Search query string",
                }
            },
            "required": ["query"],
        },
    },
}

_MAX_SEARCH_RESULTS = 3
_MAX_SEARCH_CALLS = 2  # cap per model call to avoid runaway loops


def _run_web_search(query: str) -> str:
    """Execute DuckDuckGo search, return concatenated snippets."""
    try:
        with DDGS() as ddgs:
            results = list(ddgs.text(query, max_results=_MAX_SEARCH_RESULTS))
        if not results:
            return "[no results]"
        parts = []
        for r in results:
            parts.append(f"[{r.get('title','')}] {r.get('body','')}")
        return "\n\n".join(parts)[:MAX_SOURCE_CHARS]
    except Exception as exc:
        return f"[search failed: {exc}]"


# ─────────────────────────────────────────────────────────────────────────────
# Source fetching
# ─────────────────────────────────────────────────────────────────────────────


def fetch_source(url: str) -> str:
    """Return plain text from URL (truncated). Falls back gracefully."""
    try:
        r = requests.get(
            url,
            timeout=HTTP_TIMEOUT,
            headers={"User-Agent": "Mozilla/5.0 (compatible; MantraResearch/1.0)"},
        )
        r.raise_for_status()
        text = re.sub(
            r"<(script|style)[^>]*>.*?</\1>",
            " ",
            r.text,
            flags=re.DOTALL | re.IGNORECASE,
        )
        text = re.sub(r"<[^>]+>", " ", text)
        text = re.sub(r"&[a-z]+;", " ", text)
        text = re.sub(r"\s+", " ", text).strip()
        return text[:MAX_SOURCE_CHARS]
    except Exception as exc:
        return f"[fetch failed: {exc}]"


# ─────────────────────────────────────────────────────────────────────────────
# Existing-entry index
# ─────────────────────────────────────────────────────────────────────────────


def load_existing() -> dict[str, dict]:
    """
    Load every mantra from assets/data/mantras.json (versioned envelope).
    Returns a dict keyed by lowercase value of transliteration / name / original.
    """
    idx: dict[str, dict] = {}
    if not MANTRAS_FILE.exists():
        return idx
    data = json.loads(MANTRAS_FILE.read_text())
    items = data.get("mantras", []) if isinstance(data, dict) else data
    for item in items:
        for field in ("transliteration", "name", "original"):
            key = item.get(field, "").strip().lower()
            if key:
                idx.setdefault(key, item)
    return idx


def find_match(phrase: str, existing: dict[str, dict]) -> dict | None:
    key = phrase.strip().lower()
    if key in existing:
        return existing[key]
    for k, v in existing.items():
        if key in k or k in key:
            return v
    return None


# ─────────────────────────────────────────────────────────────────────────────
# Prompts
# ─────────────────────────────────────────────────────────────────────────────

SCHEMA_COMPACT = '{"name":"...","english":"...","original":"...","transliteration":"...","abstract":"<para 1>\\n\\n<para 2>","tags":["t1","t2","t3","t4"],"tradition":"...","category":"...","difficulty":"...","targetRepetitions":108,"supportedLanguages":["sa","en"],"sources":[{"url":"...","title":"..."}]}'

SCHEMA = """{
  "name":              "<short English name for the mantra>",
  "english":           "<English translation of the mantra phrase>",
  "original":          "<original script; same as transliteration if Latin-only>",
  "transliteration":   "<romanised form>",
  "abstract":          "<paragraph one (3-4 sentences)>\\n\\n<paragraph two (3-4 sentences)>",
  "tags":              ["tag1", "tag2", "tag3", "tag4"],
  "tradition":         "<Hindu | Buddhist | Islamic | Christian | Sikh | Jain | Jewish | Taoist | Universal | Other>",
  "category":          "<sub-category, e.g. vedic | tibetan | sufi | affirmation>",
  "difficulty":        "<beginner | intermediate | advanced>",
  "targetRepetitions": 108,
  "supportedLanguages":["sa","en"],
  "sources": [
    {"url": "...", "title": "..."}
  ]
}"""


_DRAFT_SYSTEM = """\
<role>
You are a sociology scholar of world mantra traditions.
</role>

<task>
Produce a complete JSON entry for the given mantra, following the exact schema.
You may call the web_search tool to look up additional context before answering.
</task>

<rules>
<rules>
- abstract: exactly 2 paragraphs separated by \\n\\n. Each paragraph 3–4 sentences.
- abstract must be grounded in the source content provided. Do NOT fabricate \
historical claims, attributions, or benefits not supported by the source material.
- targetRepetitions: pick from 1, 3, 7, 21, 54, 108 based on the tradition.
- tags: lowercase, specific, at least 4.
- tradition: must be exactly one of: Hindu, Buddhist, Islamic, Christian, Sikh, \
Jain, Jewish, Taoist, Universal, Other.
- difficulty: must be exactly one of: beginner, intermediate, advanced.
- Do NOT include a "translations" field — translations are handled separately.
</rules>

<output_format>
You may include reasoning or commentary before the JSON.
You MUST wrap your final JSON in a ```json``` fenced code block.
Use compact single-line JSON (no pretty-printing). Schema:
{schema_compact}

For reference, the full schema with field descriptions:
{schema}
</output_format>\
""".format(schema_compact=SCHEMA_COMPACT, schema=SCHEMA)


def draft_messages(mantra: dict, source_text: str, existing: dict | None) -> list[dict]:
    """Build system + user messages for the draft prompt."""
    user_lines = []

    user_lines.append("<mantra>")
    user_lines.append(f"Phrase (canonical):  {mantra['phrase']}")
    user_lines.append(f"Language(s):         {', '.join(mantra['language'])}")
    user_lines.append(f"Tags from index:     {', '.join(mantra['tags'])}")
    user_lines.append(f"Source URLs:         {', '.join(s['url'] for s in mantra['sources'])}")
    user_lines.append("</mantra>")

    if existing:
        user_lines.append("")
        user_lines.append("<existing_entry>")
        user_lines.append("An existing entry already exists. You may improve it:")
        user_lines.append(json.dumps(existing, ensure_ascii=False))
        user_lines.append("</existing_entry>")

    if source_text and not source_text.startswith("[fetch failed"):
        user_lines.append("")
        user_lines.append("<source_content>")
        user_lines.append("Use this to verify and ground the abstract:")
        user_lines.append(source_text)
        user_lines.append("</source_content>")

    return [
        {"role": "system", "content": _DRAFT_SYSTEM},
        {"role": "user", "content": "\n".join(user_lines)},
    ]


_MERGE_SYSTEM = """\
<role>
You are a senior sociology scholar reviewing AI-generated mantra entries.
</role>

<task>
Multiple AI assistants have produced draft entries for the same mantra. \
Combine them into one optimal entry.
</task>

<rules>
- Choose the abstract that is most accurate and grounded — do not fabricate \
claims not present in any draft.
- Union all tags, remove duplicates, keep at least 4.
- Choose the most appropriate difficulty and targetRepetitions.
- tradition: must be exactly one of: Hindu, Buddhist, Islamic, Christian, Sikh, \
Jain, Jewish, Taoist, Universal, Other.
- abstract: exactly 2 paragraphs (\\n\\n separated), each 3–4 sentences.
- Treat all drafts equally regardless of their order.
</rules>

<output_format>
You may include reasoning or commentary before the JSON.
You MUST wrap your final JSON in a ```json``` fenced code block.
Use compact single-line JSON (no pretty-printing). Schema:
{schema_compact}
</output_format>\
""".format(schema_compact=SCHEMA_COMPACT)


def merge_messages(mantra: dict, *drafts: str) -> list[dict]:
    """Build system + user messages for the merge prompt."""
    user_lines = [f"Mantra phrase: {mantra['phrase']}", ""]
    for i, draft in enumerate(drafts, 1):
        user_lines.append(f"<draft_{i}>")
        user_lines.append(draft)
        user_lines.append(f"</draft_{i}>")
        user_lines.append("")
    return [
        {"role": "system", "content": _MERGE_SYSTEM},
        {"role": "user", "content": "\n".join(user_lines)},
    ]


# ─────────────────────────────────────────────────────────────────────────────
# Translation  (dedicated model, runs after merge)
# ─────────────────────────────────────────────────────────────────────────────

_TRANSLATE_SCHEMA_COMPACT = '{"translations":{' + ','.join(f'"{k}":"..."' for k in _TRANSLATE_LANGUAGES) + '}}'

_TRANSLATE_SYSTEM = """\
<role>
You are a professional translator specializing in sacred and spiritual texts.
</role>

<task>
Translate the given mantra phrase into the requested target languages. \
Translate the mantra phrase itself — not its description or abstract.
</task>

<rules>
- Produce an accurate, natural translation in each target language.
- Preserve the spiritual meaning and nuance of the original phrase.
- If the mantra is already in the target language, return it unchanged.
- If the mantra cannot be meaningfully translated (e.g. seed syllables like \
"Om"), provide a phonetic transliteration with a brief gloss in parentheses.
</rules>

<output_format>
You may include brief reasoning before the JSON.
You MUST wrap your final JSON in a ```json``` fenced code block.
Use compact single-line JSON. Schema:
{schema}
</output_format>\
""".format(schema=_TRANSLATE_SCHEMA_COMPACT)

_TRANSLATE_LANGUAGES: dict[str, str] = cfg()["enrich_mantras"]["translate_languages"]


def translate_messages(phrase: str, english: str, original: str) -> list[dict]:
    """Build messages for the translation step."""
    user_lines = [
        "<mantra>",
        f"Phrase: {phrase}",
    ]
    if english:
        user_lines.append(f"English meaning: {english}")
    if original and original != phrase:
        user_lines.append(f"Original script: {original}")
    user_lines.append("</mantra>")
    user_lines.append("")
    user_lines.append("<target_languages>")
    for code, name in _TRANSLATE_LANGUAGES.items():
        user_lines.append(f"- {code}: {name}")
    user_lines.append("</target_languages>")
    return [
        {"role": "system", "content": _TRANSLATE_SYSTEM},
        {"role": "user", "content": "\n".join(user_lines)},
    ]


async def translate_entry(entry: dict) -> dict[str, str]:
    """Call MODEL_TRANSLATOR to produce translations for a merged entry.

    Returns a dict like {"en": "...", "zh": "...", "es": "..."}.
    """
    phrase = entry.get("transliteration") or entry.get("name", "")
    english = entry.get("english", "")
    original = entry.get("original", "")
    msgs = translate_messages(phrase, english, original)
    try:
        response = await litellm.acompletion(
            model=MODEL_TRANSLATOR,
            messages=msgs,
            **TRANSLATOR_KWARGS,
        )
        raw = (response.choices[0].message.content or "").strip()
        data = parse_fenced_json(raw)
        translations = data.get("translations", data)
        if isinstance(translations, dict):
            return {k: v for k, v in translations.items() if isinstance(v, str) and v.strip()}
    except Exception:
        pass
    return {}
# ─────────────────────────────────────────────────────────────────────────────


async def call_model(model: str, messages: list[dict]) -> str:
    """
    Call the model with web_search tool support (async).
    Runs an agentic loop: if the model calls web_search, execute it and
    feed the result back, up to _MAX_SEARCH_CALLS times.
    """
    messages = list(messages)  # don't mutate the caller's list
    search_calls = 0

    while True:
        response = await litellm.acompletion(
            model=model,
            messages=messages,
            tools=[_SEARCH_TOOL_DEF],
            tool_choice="auto",
            **LLM_KWARGS,
        )
        msg = response.choices[0].message

        # No tool call → return the text content
        if not msg.tool_calls:
            return (msg.content or "").strip()

        # Tool call requested — honour up to the cap
        messages.append(msg)  # assistant turn with tool_calls

        for tc in msg.tool_calls:
            if tc.function.name == "web_search" and search_calls < _MAX_SEARCH_CALLS:
                args = json.loads(tc.function.arguments)
                result = await asyncio.to_thread(
                    _run_web_search, args.get("query", "")
                )
                search_calls += 1
            else:
                result = "[tool call skipped]"

            messages.append(
                {
                    "role": "tool",
                    "tool_call_id": tc.id,
                    "content": result,
                }
            )

        # Safety: if cap hit and model still wants to search, stop looping
        if search_calls >= _MAX_SEARCH_CALLS:
            # Drop tool-call turns to keep context small, then force JSON answer
            final_messages = [m for m in messages if not isinstance(m, dict) or m.get("role") not in ("tool",)]
            final_messages = [m for m in final_messages if not (hasattr(m, "tool_calls") and m.tool_calls)]
            final = await litellm.acompletion(
                model=model,
                messages=final_messages,
                **LLM_KWARGS,
            )
            return (final.choices[0].message.content or "").strip()


def parse_json(text: str) -> dict:
    return parse_fenced_json(text)


# ─────────────────────────────────────────────────────────────────────────────
# Grading  (single grader model, one async call per category)
# ─────────────────────────────────────────────────────────────────────────────

# Each template receives: {phrase} and {entry}
# Must instruct the grader to return ONLY: {"score": <int 0-100>, "reason": "..."}
_GRADE_PROMPTS: dict[str, str] = {

    "no_accurate_translations": """\
You are a professional linguist grading translation quality.

Mantra phrase: {phrase}
Entry JSON:
{entry}

Grade the "translations" field (en, zh, es) on a scale of 0–100.

What good translations look like:
- All three languages (en, zh, es) are present and non-empty.
- Each translation accurately conveys the mantra's literal meaning AND spiritual nuance.
- The wording is natural in the target language — not a mechanical word-for-word rendering.
- The translated text would be intelligible and meaningful to a native speaker of that language.

Scoring bands:
  90–100  All three translations present, accurate, natural, and spiritually faithful.
  70–89   All three present; one has minor awkwardness or slight inaccuracy.
  50–69   All three present but at least one has a notable inaccuracy or sounds unnatural.
  30–49   One translation missing, or two have significant errors.
  10–29   Two translations missing, or the one present is largely inaccurate.
  0–9     All translations absent, or completely wrong.

Return ONLY valid JSON, no commentary:
{{"score": <integer 0-100>, "reason": "<one sentence>"}}""",

    "abstract_quality": """\
You are a scholar grading the quality of a mantra entry's abstract.

Mantra phrase: {phrase}
Entry JSON:
{entry}

Grade the "abstract" field on a scale of 0–100.

What a high-quality abstract must contain:
- Exactly 2 paragraphs separated by a blank line.
- Paragraph 1 (3–4 sentences): origin of the mantra, the tradition it belongs to,
  its literal word-by-word meaning, and any relevant historical context.
- Paragraph 2 (3–4 sentences): how practitioners actually use the mantra,
  its spiritual or psychological effect, and what benefit is attributed to it.
- Content must be specific to THIS mantra — phrases like "this powerful mantra
  brings peace" with no further detail are considered generic filler.
- Factually consistent with known scholarship on the tradition.

Scoring bands:
  90–100  Both paragraphs present, 3–4 sentences each, specific and accurate.
  70–89   Both paragraphs present; one is slightly short or mildly generic.
  50–69   Both paragraphs present but noticeably lacking in depth or specificity.
  30–49   Only one paragraph, or content is mostly generic filler.
  10–29   Abstract is very short, vague, or contains factual errors.
  0–9     Abstract missing or completely off-topic.

Return ONLY valid JSON, no commentary:
{{"score": <integer 0-100>, "reason": "<one sentence>"}}""",

    "other_fields_accuracy": """\
You are a religion scholar grading the factual accuracy of structured fields.

Mantra phrase: {phrase}
Entry JSON:
{entry}

Grade the factual accuracy of these fields: tradition, category,
targetRepetitions, sources, and tags — on a scale of 0–100.

Criteria:
- tradition: must correctly name the religious/spiritual tradition
  (Hindu | Buddhist | Islamic | Christian | Sikh | Jain | Jewish | Taoist |
   Universal | Other).  Wrong tradition = major error.
- category: must be an appropriate sub-category (e.g. vedic, tibetan, sufi,
  affirmation, devotional). Vague or wrong = minor/major error.
- targetRepetitions: must be one of {{1, 3, 7, 21, 54, 108}} AND appropriate
  for the specific tradition and mantra type. A wrong value here is a factual error.
- sources: at least one URL must be present and plausibly relevant to this mantra.
- tags: at least 4 tags, specific to this mantra (not just "meditation" or "chant").

Scoring bands:
  90–100  All five areas accurate and appropriate.
  70–89   One minor inaccuracy (e.g. category slightly off, one tag generic).
  50–69   Two fields inaccurate, or targetRepetitions clearly wrong.
  30–49   Three fields wrong or missing, or tradition misidentified.
  10–29   Four or more fields wrong, or tradition completely wrong.
  0–9     No reliable field is correct.

Return ONLY valid JSON, no commentary:
{{"score": <integer 0-100>, "reason": "<one sentence>"}}""",

    "other_fields_quality": """\
You are grading the completeness and quality of core identification fields.

Mantra phrase: {phrase}
Entry JSON:
{entry}

Grade the quality of these fields: name, english, original, transliteration,
difficulty, and supportedLanguages — on a scale of 0–100.

Criteria:
- name: a clear, specific English name that uniquely identifies the mantra
  (not just "Vedic Mantra" or similar generic labels).
- english: an accurate literal translation of the mantra text itself.
- original: the mantra in its original script (Sanskrit Devanagari, Tibetan,
  Arabic, etc.); may equal transliteration only if the tradition uses Latin script.
- transliteration: accurate romanisation with standard diacritics where applicable
  (e.g. "Oṃ maṇi padme hūṃ", not "Om mani padme hum" for a scholarly entry).
- difficulty: beginner / intermediate / advanced, appropriate to the mantra's
  linguistic complexity and the depth of practice it traditionally requires.
- supportedLanguages: ISO codes (e.g. ["sa","en"]) that match the languages
  actually present in the entry.

Scoring bands:
  90–100  All six fields present, accurate, and high-quality.
  70–89   Five fields correct; one minor quality issue.
  50–69   Four–five fields present but at least one has notable quality issues.
  30–49   Three–four fields present or multiple quality issues.
  10–29   Fewer than three fields, or widespread inaccuracies.
  0–9     Almost nothing present or correct.

Return ONLY valid JSON, no commentary:
{{"score": <integer 0-100>, "reason": "<one sentence>"}}""",
}

# Category → YAML weight key
_GRADE_CATEGORIES = [
    "no_accurate_translations",
    "abstract_quality",
    "other_fields_accuracy",
    "other_fields_quality",
]


async def _grade_category(phrase: str, entry_text: str, category: str) -> int:
    """Ask MODEL_GRADER to score one category. Returns integer 0-100."""
    prompt = _GRADE_PROMPTS[category].format(phrase=phrase, entry=entry_text)
    try:
        response = await litellm.acompletion(
            model=MODEL_GRADER,
            messages=[{"role": "user", "content": prompt}],
            **GRADER_KWARGS,
        )
        raw = (response.choices[0].message.content or "").strip()
        data = parse_json(raw)
        return max(0, min(100, int(data.get("score", 0))))
    except Exception:
        return 0


async def grade_draft(phrase: str, entry_text: str) -> float:
    """
    Grade a student draft across all categories in parallel.
    Returns weighted score 0–100 using YAML-configured weights.
    """
    grades = await asyncio.gather(
        *(_grade_category(phrase, entry_text, cat) for cat in _GRADE_CATEGORIES),
        return_exceptions=True,
    )
    total = 0.0
    for cat, g in zip(_GRADE_CATEGORIES, grades):
        score = g if isinstance(g, int) else 0
        total += _grade_cfg.get(cat, 0) * score / 100
    return round(total, 2)


# ─────────────────────────────────────────────────────────────────────────────
# Scatter plot
# ─────────────────────────────────────────────────────────────────────────────

PLOT_OUTPUT = root_path("enrich_mantras", "output").parent / "score_scatter.png"

# Palette cycles for any number of models
_PALETTE = ["#4e8ef7", "#f76b4e", "#4ecf7a", "#f7c44e", "#b04ef7", "#4ef7e8"]
_MARKERS = ["o", "s", "^", "D", "P", "X"]


def plot_scores(results: dict) -> None:
    """
    Scatter-plot speed vs performance score for every student model.
    One series per engine (keyed by model name). Merge is excluded.
    """
    try:
        import matplotlib

        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not installed — skipping plot.")
        return

    # Collect data: series[model_name] = {"speed": [...], "score": [...]}
    series: dict[str, dict[str, list]] = {}
    for entry in results.values():
        ev = entry.get("_scores")
        if not ev:
            continue
        for model_name, d in ev.items():
            if model_name not in series:
                series[model_name] = {"speed": [], "score": []}
            series[model_name]["speed"].append(d["speed_s"])
            series[model_name]["score"].append(d["score"])

    if not series:
        print("No eval data to plot.")
        return

    fig, ax = plt.subplots(figsize=(10, 6))
    for i, (model_name, data) in enumerate(series.items()):
        colour = _PALETTE[i % len(_PALETTE)]
        marker = _MARKERS[i % len(_MARKERS)]
        # Use the bare engine name (after last '/') as label to keep legend readable
        label = model_name.split("/")[-1]
        ax.scatter(
            data["speed"],
            data["score"],
            label=label,
            color=colour,
            marker=marker,
            alpha=0.75,
            s=65,
            edgecolors="white",
            linewidths=0.5,
        )

    ax.set_xlabel("Speed — LLM call duration (seconds)", fontsize=12)
    ax.set_ylabel("Performance Score (0–100)", fontsize=12)
    ax.set_title("Student Models — Speed vs Performance per Mantra", fontsize=14)
    ax.legend(title="Model")
    ax.grid(True, linestyle="--", alpha=0.4)
    fig.tight_layout()
    fig.savefig(PLOT_OUTPUT, dpi=150)
    print(f"Scatter plot saved to {PLOT_OUTPUT}")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────


async def main() -> None:
    if not DEDUPED.exists():
        sys.exit(f"Error: {DEDUPED} not found — run dedup_mantras.py first.")

    deduped: dict[str, dict] = json.loads(DEDUPED.read_text())
    mantras = list(deduped.values())
    total = len(mantras)

    _banner(
        "Stage 4: enrich_mantras",
        [
            f"###   Input:           {DEDUPED}  ({total} phrases)",
            f"###   Output:          {OUTPUT}",
            f"###   Student models:  {', '.join(STUDENT_MODELS)}",
            f"###   Merge model:     {MODEL_MERGE}",
            f"###   Grader model:    {MODEL_GRADER}",
            f"###   Translator:     {MODEL_TRANSLATOR}",
            f"###   llm_options:     {cfg()['enrich_mantras'].get('llm_options', {})}",
            f"###   max_source_chars:{MAX_SOURCE_CHARS}",
            f"###   http_timeout:    {HTTP_TIMEOUT} s",
            f"###   grade weights:   {_grade_cfg}",
        ],
    )
    print()

    # Resume from existing output
    results: dict[str, dict] = {}
    if OUTPUT.exists():
        results = json.loads(OUTPUT.read_text())
        print(
            f"Resuming: {len(results)} entries already done, {total - len(results)} remaining."
        )

    existing = load_existing()

    with tqdm(total=total, desc="Enriching mantras", unit="mantra") as pbar:
        for mantra in mantras:
            phrase = mantra["phrase"]

            if phrase in results:
                pbar.update(1)
                continue

            pbar.set_postfix_str(f"'{phrase[:35]}'")
            t0 = time.time()

            # 1. Fetch source context (blocking I/O → thread)
            source_text = ""
            for src in mantra["sources"][:2]:
                text = await asyncio.to_thread(fetch_source, src["url"])
                if not text.startswith("[fetch failed"):
                    source_text = text
                    break

            # 2. Find existing library entry
            match = find_match(phrase, existing)

            # 3. Build draft messages
            msgs = draft_messages(mantra, source_text, match)

            # 4. Run all student models in parallel — each timed individually
            async def timed_call(model: str, m: list[dict]) -> tuple[str, float]:
                t = time.time()
                try:
                    result = await call_model(model, m)
                except Exception as exc:
                    result = json.dumps({"_error": f"model call failed: {exc}"})
                return result, time.time() - t

            raw_results = await asyncio.gather(
                *(timed_call(model, msgs) for model in STUDENT_MODELS),
                return_exceptions=True,
            )
            drafts: dict[str, tuple[str, float]] = {}
            for model, res in zip(STUDENT_MODELS, raw_results):
                if isinstance(res, Exception):
                    drafts[model] = (json.dumps({"_error": str(res)}), 0.0)
                else:
                    drafts[model] = res  # type: ignore[assignment]

            draft_texts = [drafts[m][0] for m in STUDENT_MODELS]

            # 5. Merge all drafts
            try:
                merged_raw = await call_model(MODEL_MERGE, merge_messages(mantra, *draft_texts))
            except Exception as exc:
                merged_raw = json.dumps({"_error": f"merge failed: {exc}"})

            # 6. Parse — fall back: merge → each student in order → raw error
            entry: dict = {}
            for candidate in [merged_raw, *draft_texts]:
                try:
                    entry = parse_json(candidate)
                    break
                except (json.JSONDecodeError, ValueError):
                    continue
            if not entry:
                entry = {"_raw_merge": merged_raw, "_error": "json parse failed"}
                for i, t in enumerate(draft_texts):
                    entry[f"_raw_{i}"] = t

            # 7. Translate (dedicated translator model, after merge)
            if "_error" not in entry:
                translations = await translate_entry(entry)
                if translations:
                    entry["translations"] = translations

            # 8. Grade each student draft in parallel (grader model, single standard)
            grade_scores = await asyncio.gather(
                *(grade_draft(phrase, drafts[model][0]) for model in STUDENT_MODELS),
                return_exceptions=True,
            )
            entry["_scores"] = {
                model: {
                    "speed_s": round(drafts[model][1], 2),
                    "score": score if isinstance(score, float) else 0.0,
                }
                for model, score in zip(STUDENT_MODELS, grade_scores)
            }

            results[phrase] = entry

            # Write after every entry so a crash loses at most one item
            OUTPUT.write_text(json.dumps(results, indent=2, ensure_ascii=False))

            pbar.update(1)

    print(f"\nDone. {len(results)}/{total} entries written to {OUTPUT}")
    _banner(
        "Results: enrich_mantras",
        [
            f"###   Done:     {len(results)}/{total} entries written",
            f"###   Written:  {OUTPUT}",
        ],
    )
    plot_scores(results)


if __name__ == "__main__":
    asyncio.run(main())
