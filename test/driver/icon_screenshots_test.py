"""
Host-side screenshot validation for icon placement integration tests.

Two complementary checks per screenshot:

1. OCR text anchors — confirms the correct screen is VISUALLY rendered (not just
   in the widget tree). Catches rendering bugs that Flutter-only assertions miss,
   e.g. text present in the widget tree but invisible due to theme/opacity.

2. Accent-colour presence — verifies the app's violet theme colour (#7C3AED /
   #8B5CF6) is present in the screenshot, confirming that Material Icons and
   themed decorations rendered and are not missing due to asset or font failures.
   This is the icon-era equivalent of the old emoji glyph check.

Usage: python3 test/driver/icon_screenshots_test.py <screen_name> <image_path>
Exit 0 = all checks pass.
Exit 1 = bad args, missing text anchors, or accent colour absent.
"""

from PIL import Image
import pytesseract
import sys


# ── Screen text anchors ──────────────────────────────────────────────────────
# Use stable, always-visible labels; avoid hint/placeholder text which may
# render in a lighter weight that OCR misses.
EXPECTED_TEXT = {
    'mantra_library': [
        'Mantra Library',
        'Sacred texts across traditions',
    ],
    'progress': [
        'Progress',
        'Current Streak',
        'Achievements',
    ],
    'session_complete': [
        'Session Complete',
        'repetitions',
    ],
}

# ── Accent-colour check ──────────────────────────────────────────────────────
# The app's violet palette sits at hue ≈ 258–262° (HSV).
# Pillow's HSV mode encodes hue in [0, 255] (255 = 360°), giving ≈ 182–186.
# Use a generous band to tolerate rendering and compression variation.
_HUE_MIN = 170   # lower bound on the violet hue band
_HUE_MAX = 200   # upper bound on the violet hue band
_SAT_MIN = 100   # exclude near-grey pixels (saturation < 100/255)
_VAL_MIN = 80    # exclude near-black pixels (value   < 80/255)
_PIXEL_THRESHOLD = 50  # minimum violet-hued pixels required


def normalize(text: str) -> str:
    return ' '.join(text.lower().split())


def check_text_anchors(image_path: str, expected: list[str]) -> dict[str, bool]:
    img = Image.open(image_path)
    text = normalize(pytesseract.image_to_string(img))
    return {anchor: normalize(anchor) in text for anchor in expected}


def count_accent_pixels(image_path: str) -> int:
    """Count pixels in the violet hue/saturation/value bands."""
    img = Image.open(image_path).convert('HSV')
    return sum(
        1 for h, s, v in img.getdata()
        if _HUE_MIN <= h <= _HUE_MAX and s >= _SAT_MIN and v >= _VAL_MIN
    )


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: python3 test/driver/icon_screenshots_test.py <screen_name> <image_path>')
        sys.exit(1)

    screen_name = sys.argv[1]
    image_path = sys.argv[2]
    expected = EXPECTED_TEXT.get(screen_name)

    if expected is None:
        print(f"Unknown screen: '{screen_name}'. Known screens: {list(EXPECTED_TEXT.keys())}")
        sys.exit(1)

    # ── 1. OCR text anchors ──────────────────────────────────────────────────
    text_results = check_text_anchors(image_path, expected)
    print(f'Text anchors for [{screen_name}]:')
    for anchor, found in text_results.items():
        print(f"  {'OK' if found else 'MISSING':7}  {anchor!r}")

    # ── 2. Accent colour ─────────────────────────────────────────────────────
    violet_px = count_accent_pixels(image_path)
    colour_ok = violet_px >= _PIXEL_THRESHOLD
    print(
        f'Accent colour (violet): {violet_px} px  '
        f'(need \u2265{_PIXEL_THRESHOLD}) \u2014 {"OK" if colour_ok else "MISSING"}'
    )

    # ── Result ───────────────────────────────────────────────────────────────
    missing_text = [a for a, found in text_results.items() if not found]
    failed = bool(missing_text) or not colour_ok

    if missing_text:
        print(f'FAILED \u2014 missing text anchors: {missing_text}')
    if not colour_ok:
        print(f'FAILED \u2014 accent colour not detected ({violet_px} px < {_PIXEL_THRESHOLD})')

    if not failed:
        print('PASSED')
        sys.exit(0)
    else:
        sys.exit(1)