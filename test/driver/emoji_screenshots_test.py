"""
Emoji presence check via OCR on a Flutter screenshot.
Usage: python3 emoji_screenshot_test.py <screen_name> <image_path>
Exit 0 = all expected emojis found, Exit 1 = missing emojis or bad args.
"""

from PIL import Image
import pytesseract
import sys

EXPECTED_EMOJIS = {
    'mantra_library':  ['🔥', '🧘', '⭐', '🙏', '🔒', '📿'],
    'progress':        ['🔥', '⭐', '🧘', '📿', '🔒', '🙏'],
    'session_complete':['🙏', '⭐'],
}

def check_emojis(image_path: str, expected: list[str]) -> dict[str, bool]:
    img = Image.open(image_path)
    text = pytesseract.image_to_string(img)
    return {emoji: emoji in text for emoji in expected}

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python3 emoji_screenshot_test.py <screen_name> <image_path>")
        sys.exit(1)

    screen_name = sys.argv[1]
    image_path  = sys.argv[2]
    expected    = EXPECTED_EMOJIS.get(screen_name)

    if expected is None:
        print(f"Unknown screen: '{screen_name}'. Known screens: {list(EXPECTED_EMOJIS.keys())}")
        sys.exit(1)

    results = check_emojis(image_path, expected)

    print(f"Emoji check for [{screen_name}]:")
    for emoji, found in results.items():
        print(f"  {emoji}: {'✅' if found else '❌ MISSING'}")

    if not all(results.values()):
        missing = [e for e, found in results.items() if not found]
        print(f"FAILED — missing emojis: {missing}")
        sys.exit(1)

    print("PASSED — all expected emojis present.")
    sys.exit(0)
