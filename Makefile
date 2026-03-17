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

# Run lint + unit + widget tests (no device needed — works on macOS and Linux)
# --reporter expanded prints each test name as it runs.
test:
	@flutter analyze
	@flutter test test/unit/ test/widget/ --reporter expanded

# Run integration tests against the Linux/MacOS target.
# Each test file is run as a separate invocation so the app process starts and
# stops cleanly between files — running them together in one `flutter test
# integration_test/` call causes the second app launch to fail on desktop
# targets because the first instance hasn't fully terminated yet.
test-integration:
	@if [ "$(TARGET)" = "linux" ]; then \
		for f in integration_test/*_test.dart; do \
			xvfb-run --auto-servernum flutter test "$$f" -d $(TARGET) || exit 1; \
		done \
	elif [ "$(TARGET)" = "macos" ]; then \
		for f in integration_test/*_test.dart; do \
			flutter test "$$f" -d $(TARGET) || exit 1; \
		done \
	elif [ "$(TARGET)" = "windows" ]; then \
		for f in integration_test/*_test.dart; do \
			flutter test "$$f" -d $(TARGET) || exit 1; \
		done \
	else \
		echo "Error: Target '$(TARGET)' test-integration is currently unsupported."; \
		exit 1; \
	fi
