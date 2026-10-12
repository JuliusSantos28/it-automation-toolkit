#!/usr/bin/env python3
"""Parse a log file and summarize errors by type.

Usage:
    python log_parser.py /var/log/app.log
    python log_parser.py /var/log/app.log --top 20 --level ERROR

Reads the file line by line (memory-friendly for large logs), matches a
configurable error pattern, and prints the most common messages.
No third-party dependencies.
"""
import argparse
import re
from collections import Counter


def parse_args():
    p = argparse.ArgumentParser(description="Summarize errors in a log file.")
    p.add_argument("logfile", help="Path to the log file")
    p.add_argument("--level", default="ERROR",
                   help="Log level to filter on (default: ERROR)")
    p.add_argument("--top", type=int, default=10,
                   help="Show the N most common messages (default: 10)")
    p.add_argument("--pattern", default=r"ERROR\s*[:\-]?\s*(.+)",
                   help="Regex with one capture group for the message")
    return p.parse_args()


def main():
    args = parse_args()
    matcher = re.compile(args.pattern)
    counts = Counter()
    total = 0

    with open(args.logfile, errors="replace") as fh:
        for line in fh:
            if args.level not in line:
                continue
            total += 1
            m = matcher.search(line)
            message = m.group(1).strip() if m else line.strip()[:120]
            # Normalize numbers/IDs so similar errors group together
            message = re.sub(r"\d+", "#", message)
            counts[message] += 1

    print(f"Scanned {args.logfile}: {total} '{args.level}' lines, "
          f"{len(counts)} unique messages\n")
    print(f"Top {args.top} most common:")
    for message, count in counts.most_common(args.top):
        print(f"  {count:6d}x  {message[:100]}")


if __name__ == "__main__":
    main()
