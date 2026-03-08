# ==============================================================
#  myMantra — Makefile
#  Targets configured in target.json
# ==============================================================
#  make install     [TARGET=<name>]  install tools + verify environment
#  make build       [TARGET=<name>]  build artifacts (all build=true targets)
#  make run         [TARGET=<name>]  run  (TARGET required if >1 build=true)
#  make debug       [TARGET=<name>]  debug (TARGET required if >1 debug=true)
#  make clean                        remove all build artifacts
#  make mantra-db                    run the full mantra discovery pipeline
# ==============================================================

TARGET ?=
_T     := $(if $(TARGET),--target $(TARGET),)

.PHONY: install build run debug clean test test-integration mantra-db

install:
	@bash make/install.sh $(_T)

build:
	@bash make/build.sh $(_T)

run:
	@bash make/run.sh $(_T)

debug:
	@bash make/run.sh --debug $(_T)

clean:
	@bash make/clean.sh

# Run lint + unit + widget tests (no device needed — works on macOS and Linux)
# --reporter expanded prints each test name as it runs.
test:
	@flutter analyze
	@flutter test test/unit/ test/widget/ --reporter expanded

# Run integration tests against the Linux/MacOS target
test-integration:
	@if [ "$(TARGET)" = "linux" ]; then \
		xvfb-run flutter test integration_test/ -d $(TARGET); \
	elif [ "$(TARGET)" = "macos" ]; then \
		flutter test integration_test/ -d $(TARGET); \
	else \
		echo "Error: Target '$(TARGET)' test-integration is currently unsupported."; \
		exit 1; \
	fi

# ── mantra-db pipeline ────────────────────────────────────────────────────────
# Delegates to make/mantra-db/Makefile — see that file for all sub-targets.
# Full pipeline + merge: make mantra-db
# Check prerequisites:   make mantra-db ARGS=prerequisites
ARGS ?= all
mantra-db:
	@$(MAKE) -f make/mantra-db/Makefile $(ARGS)
