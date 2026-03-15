"""
Host-side screenshot validation for icon placement integration tests.

The app-side integration test is responsible for asserting exact Material icon
widgets. This script validates that each saved screenshot corresponds to the
expected screen by checking stable textual anchors via OCR.

Usage: python3 test/driver/icon_screenshots_test.py <screen_name> <image_path>
Exit 0 = screenshot looks valid for the named checkpoint.
Exit 1 = bad args, OCR failure, or missing expected anchors.
"""

from PIL import Image
import pytesseract
import sys


EXPECTED_TEXT = {
    'mantra_library': ['Mantra Library', 'Search library'],
    'progress': ['Progress', 'Achievements'],
    'session_complete': ['Session Complete'],
}


def normalize(text: str) -> str:
    return ' '.join(text.lower().split())


def validate_screen(image_path: str, expected: list[str]) -> dict[str, bool]:
    img = Image.open(image_path)
    text = normalize(pytesseract.image_to_string(img))
    return {anchor: normalize(anchor) in text for anchor in expected}


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

    results = validate_screen(image_path, expected)

    print(f'Validation for [{screen_name}]:')
    for anchor, found in results.items():
        print(f"  {anchor}: {'OK' if found else 'MISSING'}")

    if not all(results.values()):
        missing = [anchor for anchor, found in results.items() if not found]
        print(f'FAILED - missing anchors: {missing}')
        sys.exit(1)

    print('PASSED - expected anchors present.')
    sys.exit(0)