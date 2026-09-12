from pathlib import Path
import csv
import shutil


# ---------------------------------------------------------
# Project paths
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[2]

DATASET_ROOT = (
    PROJECT_ROOT
    / "datasets"
    / "SKU-110K"
    / "SKU110K_fixed"
)

IMAGE_ROOT = DATASET_ROOT / "images"
ANNOTATION_ROOT = DATASET_ROOT / "annotations"

OUTPUT_ROOT = (
    PROJECT_ROOT
    / "datasets"
    / "SKU-110K"
    / "yolo"
)


# ---------------------------------------------------------
# Dataset splits
# ---------------------------------------------------------

SPLITS = {
    "train": "annotations_train.csv",
    "val": "annotations_val.csv",
    "test": "annotations_test.csv",
}


# ---------------------------------------------------------
# Convert one split
# ---------------------------------------------------------

def convert_split(split_name: str, csv_name: str) -> None:
    annotation_file = ANNOTATION_ROOT / csv_name

    if not annotation_file.exists():
        raise FileNotFoundError(
            f"Annotation file not found: {annotation_file}"
        )

    output_image_dir = OUTPUT_ROOT / "images" / split_name
    output_label_dir = OUTPUT_ROOT / "labels" / split_name

    output_image_dir.mkdir(parents=True, exist_ok=True)
    output_label_dir.mkdir(parents=True, exist_ok=True)

    # image_name -> list of YOLO annotation lines
    labels = {}

    with annotation_file.open(
        "r",
        newline="",
        encoding="utf-8"
    ) as f:

        reader = csv.reader(f)

        for row_number, row in enumerate(reader, start=1):

            if len(row) != 8:
                raise ValueError(
                    f"Unexpected row {row_number} in "
                    f"{annotation_file}: {row}"
                )

            image_name = row[0]

            x_min = float(row[1])
            y_min = float(row[2])
            x_max = float(row[3])
            y_max = float(row[4])

            class_name = row[5]

            image_width = float(row[6])
            image_height = float(row[7])

            if class_name != "object":
                raise ValueError(
                    f"Unexpected class '{class_name}' "
                    f"in {annotation_file}"
                )

            if x_max <= x_min or y_max <= y_min:
                raise ValueError(
                    f"Invalid bounding box at row "
                    f"{row_number}: {row}"
                )

            # -------------------------------------------------
            # Convert XYXY -> YOLO normalized XYWH
            # -------------------------------------------------

            box_width = x_max - x_min
            box_height = y_max - y_min

            x_center = (x_min + x_max) / 2.0
            y_center = (y_min + y_max) / 2.0

            x_center /= image_width
            y_center /= image_height
            box_width /= image_width
            box_height /= image_height

            # SKU-110K has one generic object class.
            class_id = 0

            yolo_line = (
                f"{class_id} "
                f"{x_center:.6f} "
                f"{y_center:.6f} "
                f"{box_width:.6f} "
                f"{box_height:.6f}"
            )

            labels.setdefault(
                image_name,
                []
            ).append(yolo_line)

    # ---------------------------------------------------------
    # Write labels and copy images
    # ---------------------------------------------------------

    converted = 0

    for image_name, yolo_lines in labels.items():

        source_image = IMAGE_ROOT / image_name

        if not source_image.exists():
            raise FileNotFoundError(
                f"Image not found: {source_image}"
            )

        destination_image = (
            output_image_dir / image_name
        )

        destination_label = (
            output_label_dir
            / Path(image_name).with_suffix(".txt").name
        )

        shutil.copy2(
            source_image,
            destination_image
        )

        destination_label.write_text(
            "\n".join(yolo_lines) + "\n",
            encoding="utf-8"
        )

        converted += 1

    print(
        f"{split_name}: converted {converted} images"
    )


# ---------------------------------------------------------
# Main
# ---------------------------------------------------------

def main() -> None:

    if not DATASET_ROOT.exists():
        raise FileNotFoundError(
            f"Dataset directory not found: {DATASET_ROOT}"
        )

    if not IMAGE_ROOT.exists():
        raise FileNotFoundError(
            f"Image directory not found: {IMAGE_ROOT}"
        )

    if not ANNOTATION_ROOT.exists():
        raise FileNotFoundError(
            f"Annotation directory not found: {ANNOTATION_ROOT}"
        )

    print("Dataset root:")
    print(DATASET_ROOT)

    print("\nStarting conversion...\n")

    for split_name, csv_name in SPLITS.items():
        convert_split(split_name, csv_name)

    print("\nDataset conversion completed successfully.")


if __name__ == "__main__":
    main()