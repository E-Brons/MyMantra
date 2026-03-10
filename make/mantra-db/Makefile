# ==============================================================================
#  make/mantra-db/Makefile
#  Mantra DB pipeline — file-based stages driven by settings.yml
#
#  Invoke via project root:   make mantra-db
#  Or directly:               make -f make/mantra-db/Makefile [target]
#
#  Targets:
#    all            Run full pipeline (stages 1–5 → assets/data/mantras.json)
#    clean          Remove all tmp/ pipeline outputs
#    prerequisites  Check pip packages and Ollama models from settings.yml
# ==============================================================================
SHELL := /bin/bash
.ONESHELL:

SELF     := $(abspath $(lastword $(MAKEFILE_LIST)))
SCRIPTS  := $(dir $(SELF))
SETTINGS := $(SCRIPTS)/settings.yml
ROOT     := $(abspath $(SCRIPTS)../../)

# ── read file paths from settings.yml (one Python call each) ──────────────────
_cfg = $(shell python3 -c "import yaml; c=yaml.safe_load(open('$(SETTINGS)')); print(c$(1))" 2>/dev/null)

URLS_FILE  := $(call _cfg,['search_web']['output'])
INDEX_FILE := $(call _cfg,['extract_mantra']['output'])
DEDUPED    := $(call _cfg,['translate_n_dedup']['output'])
ENRICHED   := $(call _cfg,['enrich_mantras']['output'])
MERGED     := $(call _cfg,['merge_mantras']['output'])
# Stage 5 uses a stamp file so $(MERGED) timestamp doesn't gate re-runs
# ($(MERGED) is updated/merged, not created fresh, so its mtime is unreliable)
STAMP5     := $(dir $(ENRICHED)).stage5_merged

PIPELINE_STR = Mantra DB Pipeline:  WWW -(1)-> $(URLS_FILE) -(2)-> ${INDEX_FILE} -(3)-> ${DEDUPED} -(4)-> ${ENRICHED} -(5)-> ${MERGED}
LINE_LENGTH = $(shell echo -n '$(PIPELINE_STR)' | wc -c)
# ── phony targets ──────────────────────────────────────────────────────────────
.PHONY: all prerequisites clean

all: $(STAMP5)

# ── prerequisites ─────────────────────────────────────────────────────────────
prerequisites: $(SETTINGS)
	@cd $(ROOT)
	@echo 'URLS_FILE : $(URLS_FILE)'
	@printf '%*s\n' $(LINE_LENGTH) '' | tr ' ' '-'
	@echo '$(PIPELINE_STR)'
	@printf '%*s\n' $(LINE_LENGTH) '' | tr ' ' '-'
	@python3 $(SCRIPTS)check_prerequisites.py

# ── stage 1: discover URLs ────────────────────────────────────────────────────
$(URLS_FILE): | prerequisites
	@mkdir -p $(dir $@)
	@printf '%*s\n' $(LINE_LENGTH) '' | tr ' ' '-'
	@python3 $(SCRIPTS)search_for_urls.py

# ── stage 2: extract mantras from pages ──────────────────────────────────────
$(INDEX_FILE): $(URLS_FILE) | prerequisites
	@printf '%*s\n' $(LINE_LENGTH) '' | tr ' ' '-'
	@python3 $(SCRIPTS)extract_mantras.py

# ── stage 3: translate, deduplicate and apply aliases ────────────────────────
$(DEDUPED): $(INDEX_FILE) | prerequisites
	@printf '%*s\n' $(LINE_LENGTH) '' | tr ' ' '-'
	@python3 $(SCRIPTS)translate_n_dedup.py

# ── stage 4: enrich with LLMs ────────────────────────────────────────────────
$(ENRICHED): $(DEDUPED) | prerequisites
	@printf '%*s\n' $(LINE_LENGTH) '' | tr ' ' '-'
	@python3 $(SCRIPTS)enrich_mantras.py

# ── stage 5: merge into library ──────────────────────────────────────────────
# Targets a stamp file, not $(MERGED) directly — $(MERGED) is updated on each
# run (not created fresh), so its mtime would make Make skip stage 5 forever.
$(STAMP5): $(ENRICHED) | prerequisites
	@printf '%*s\n' $(LINE_LENGTH) '' | tr ' ' '-'
	@python3 $(SCRIPTS)merge_mantras.py
	@touch $(STAMP5)

# ── clean ─────────────────────────────────────────────────────────────────────
clean:
	@rm -f $(URLS_FILE) ${INDEX_FILE} ${DEDUPED} ${ENRICHED} ${STAMP5}
	@echo "Pipeline outputs removed. ($(MERGED) kept — delete manually if needed)"
