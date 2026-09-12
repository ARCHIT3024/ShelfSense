from pathlib import Path
from PIL import Image

ROOT = Path("datasets/SKU-110K/yolo")

bad = []

images = list(ROOT.rglob("*.jpg"))

print(f"Checking {len(images)} images...")

for i, path in enumerate(images, start=1):
    try:
        with Image.open(path) as img:
            img.verify()
    except Exception as e:
        bad.append((path, str(e)))

    if i % 1000 == 0:
        print(f"Checked {i}/{len(images)}")

print()
print(f"Bad images: {len(bad)}")

for path, error in bad:
    print(path)
    print(" ", error)