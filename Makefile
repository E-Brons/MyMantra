# ==============================================================
#  myMantra — Makefile
#  Targets configured in target.json
# ==============================================================
#  make install  [TARGET=<name>]  install tools + verify environment
#  make build    [TARGET=<name>]  build artifacts (all build=true targets)
#  make run      [TARGET=<name>]  run  (TARGET required if >1 build=true)
#  make debug    [TARGET=<name>]  debug (TARGET required if >1 debug=true)
#  make clean                     remove all build artifacts
# ==============================================================

TARGET ?=
_T     := $(if $(TARGET),--target $(TARGET),)

.PHONY: install build run debug clean test test-integration

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

# Run unit + widget tests (no device needed — works on macOS and Linux)
# --reporter expanded prints each test name as it runs.
test:
	@flutter test test/unit/ test/widget/ --reporter expanded

# Run integration tests against the Linux desktop target (Linux only, requires xvfb)
test-integration:
	@xvfb-run flutter test integration_test/ -d linux
