from pathlib import Path
import random

PROJECT_ROOT = Path(__file__).resolve().parents[2]

DATASET_ROOT = (
    PROJECT_ROOT
    / "datasets"
    / "SKU-110K"
    / "yolo"
)

TRAIN_IMAGE_DIR = DATASET_ROOT / "images" / "train"
VAL_IMAGE_DIR = DATASET_ROOT / "images" / "val"

OUTPUT_DIR = DATASET_ROOT / "subset"

TRAIN_COUNT = 3000
RANDOM_SEED = 42


def main() -> None:
    random.seed(RANDOM_SEED)

    train_images = sorted(TRAIN_IMAGE_DIR.glob("*.jpg"))

    if len(train_images) < TRAIN_COUNT:
        raise ValueError(
            f"Only {len(train_images)} training images found."
        )

    selected = random.sample(train_images, TRAIN_COUNT)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    train_list = OUTPUT_DIR / "train.txt"
    val_list = OUTPUT_DIR / "val.txt"

    train_list.write_text(
        "\n".join(
            str(p.resolve()) for p in selected
        ) + "\n",
        encoding="utf-8",
    )

    val_images = sorted(VAL_IMAGE_DIR.glob("*.jpg"))

    val_list.write_text(
        "\n".join(
            str(p.resolve()) for p in val_images
        ) + "\n",
        encoding="utf-8",
    )

    print(f"Training subset: {len(selected)} images")
    print(f"Validation set: {len(val_images)} images")
    print(f"Random seed: {RANDOM_SEED}")
    print(f"Subset directory: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
