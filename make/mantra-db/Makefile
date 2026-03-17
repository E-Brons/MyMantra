# ==============================================================================
#  make/mantra-db/Makefile
#  Mantra DB pipeline — file-based stages driven by settings.yml
#
#  Invoke via project root:   make mantra-db
#  Or directly:               make -f make/mantra-db/Makefile [target]
#
#  Targets:
#    all            Run pipeline stages 1–4 (enrich mantras)
#    deploy         Deploy enriched mantras to assets/data/mantras.json
#    clean          Remove all tmp/ pipeline outputs
#    prerequisites  Check pip packages and Ollama models from settings.yml
# ==============================================================================
SHELL := /bin/bash
.ONESHELL:

PYTHON ?= python3

SELF     := $(abspath $(lastword $(MAKEFILE_LIST)))
SCRIPTS  := $(dir $(SELF))
SETTINGS := $(SCRIPTS)/settings.yml
ROOT     := $(abspath $(SCRIPTS)../../)

# ── read file paths from settings.yml (one Python call each) ──────────────────
_cfg = $(shell $(PYTHON) -c "import yaml; c=yaml.safe_load(open('$(SETTINGS)')); v=c$(1); print(v if v is not None else '')" 2>/dev/null)

URLS_FILE  := $(call _cfg,['search_web']['output'])
INDEX_FILE := $(call _cfg,['extract_mantra']['output'])
DEDUPED    := $(call _cfg,['translate_n_dedup']['output'])
ENRICHED   := $(call _cfg,['enrich_mantras']['output'])
DEPLOYED   := $(call _cfg,['deploy']['output'])

# Check parsing filenames failed (commonly: PyYAML missing in the active venv), `_cfg` returns
ifeq ($(strip $(ENRICHED)),)
$(error Failed to read ['enrich_mantras']['output'] from $(SETTINGS). Is PyYAML installed for $(PYTHON)? Try: $(PYTHON) -m pip install pyyaml)
endif

PIPELINE_STR = Mantra DB Pipeline:  WWW -(1)-> $(URLS_FILE) -(2)-> ${INDEX_FILE} -(3)-> ${DEDUPED} -(4)-> ${ENRICHED} -(deploy)-> ${DEPLOYED}
LINE_LENGTH = $(shell echo -n '$(PIPELINE_STR)' | wc -c)
# ── phony targets ──────────────────────────────────────────────────────────────
.PHONY: all deploy prerequisites clean

all: $(ENRICHED)

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

# ── stage 5: deploy to live database (explicit target, not in default) ───────
deploy: $(ENRICHED)
	@printf '%*s\n' $(LINE_LENGTH) '' | tr ' ' '-'
	@python3 $(SCRIPTS)deploy_mantras.py

# ── clean ─────────────────────────────────────────────────────────────────────
clean:
	@rm -f $(URLS_FILE) ${INDEX_FILE} ${DEDUPED} ${ENRICHED}
	@echo "Pipeline outputs removed. ($(DEPLOYED) kept — delete manually if needed)"
