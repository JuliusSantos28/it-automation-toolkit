#!/usr/bin/env python3
"""Organize a messy directory by moving files into subfolders by extension.

Usage:
    python bulk_file_organizer.py ~/Downloads
    python bulk_file_organizer.py ~/Downloads --dry-run

Supports --dry-run to preview moves without changing anything.
Unknown extensions go to a '_misc' folder. No third-party dependencies.
"""
import argparse
import shutil
from pathlib import Path

# Extension -> folder name
CATEGORIES = {
    ".pdf": "documents", ".docx": "documents", ".txt": "documents",
    ".xlsx": "documents", ".csv": "documents",
    ".jpg": "images", ".jpeg": "images", ".png": "images", ".gif": "images",
    ".mp4": "videos", ".mov": "videos",
    ".zip": "archives", ".tar": "archives", ".gz": "archives",
    ".ps1": "scripts", ".py": "scripts", ".sh": "scripts",
}


def parse_args():
    p = argparse.ArgumentParser(description="Organize files by extension.")
    p.add_argument("directory", help="Directory to organize")
    p.add_argument("--dry-run", action="store_true",
                   help="Show what would happen without moving files")
    return p.parse_args()


def main():
    args = parse_args()
    root = Path(args.directory).expanduser().resolve()
    if not root.is_dir():
        raise SystemExit(f"Not a directory: {root}")

    moved = 0
    for item in root.iterdir():
        if not item.is_file() or item.name.startswith("."):
            continue
        folder = CATEGORIES.get(item.suffix.lower(), "_misc")
        target = root / folder / item.name
        if target.exists():
            print(f"SKIP (exists): {item.name}")
            continue
        print(f"{'[dry-run] ' if args.dry_run else ''}{item.name} -> {folder}/")
        if not args.dry_run:
            (root / folder).mkdir(exist_ok=True)
            shutil.move(str(item), str(target))
            moved += 1

    print(f"\nDone: {moved} file(s) moved." if not args.dry_run
          else "\nDry run complete — nothing was moved.")


if __name__ == "__main__":
    main()
