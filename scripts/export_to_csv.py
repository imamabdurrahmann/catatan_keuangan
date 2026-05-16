#!/usr/bin/env python3
"""
Export SQLite database from catatan_keuangan app to CSV files.

Usage:
    python export_to_csv.py [OPTIONS]

Options:
    --db-path PATH       Path to SQLite database (default: keuangan.db in current dir,
                         or standard Android path)
    --output-dir DIR     Output directory for CSV files (default: ./csv_export)
    --tables TABLE,...   Comma-separated list of tables to export (default: all)
    --android            Use standard Android database path
    -q, --quiet          Suppress verbose output

Examples:
    # Export all tables from local database
    python export_to_csv.py

    # Export from Android device/emulator (after adb pull)
    python export_to_csv.py --db-path ./keuangan.db

    # Export specific tables
    python export_to_csv.py --tables transaksi,dompet,kategori

    # Export to custom output directory
    python export_to_csv.py --output-dir ./exports
"""

import argparse
import csv
import os
import sqlite3
import sys
from pathlib import Path

# Standard Android sqflite database path pattern
ANDROID_DB_PATTERN = os.path.expanduser(
    "~/.local/share/Android/data/org.catatan_keuangan.catatan_keuangan/files/"
)

DEFAULT_TABLES = ["transaksi", "dompet", "budget", "kategori", "pengaturan"]


def parse_args():
    parser = argparse.ArgumentParser(
        description="Export SQLite database from catatan_keuangan to CSV files.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--db-path",
        type=str,
        default=None,
        help="Path to SQLite database file (default: auto-detect)",
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default=None,
        help="Directory to write CSV files (default: ./csv_export)",
    )
    parser.add_argument(
        "--tables",
        type=str,
        default=None,
        help="Comma-separated list of tables to export (default: all tables)",
    )
    parser.add_argument(
        "--android",
        action="store_true",
        help="Use standard Android app database path",
    )
    parser.add_argument(
        "-q", "--quiet",
        action="store_true",
        help="Suppress verbose output",
    )
    return parser.parse_args()


def find_database(db_path_arg=None, android_mode=False):
    """Locate the SQLite database file."""
    candidates = []

    if db_path_arg:
        candidates.append(db_path_arg)
        if not db_path_arg.endswith(".db"):
            candidates.append(f"{db_path_arg}.db")

    if android_mode:
        candidates.extend([
            os.path.join(ANDROID_DB_PATTERN, "keuangan.db"),
            os.path.join(ANDROID_DB_PATTERN, "databases", "keuangan.db"),
        ])

    candidates.extend([
        "keuangan.db",
        os.path.join(os.getcwd(), "keuangan.db"),
        os.path.join(os.path.dirname(__file__), "..", "keuangan.db"),
    ])

    for candidate in candidates:
        resolved = os.path.abspath(os.path.expanduser(candidate))
        if os.path.isfile(resolved):
            return resolved

    # Return first candidate as fallback (will trigger readable check)
    return os.path.abspath(candidates[0]) if candidates else "keuangan.db"


def get_tables(conn):
    """Get list of user tables (excluding sqlite internal tables)."""
    cursor = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    )
    return [row[0] for row in cursor.fetchall()]


def export_table_to_csv(conn, table_name, output_dir, quiet=False):
    """Export a single table to a CSV file."""
    csv_path = os.path.join(output_dir, f"{table_name}.csv")

    cursor = conn.execute(f"SELECT * FROM {table_name}")
    headers = [description[0] for description in cursor.description]
    rows = cursor.fetchall()

    with open(csv_path, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(headers)
        writer.writerows(rows)

    if not quiet:
        print(f"  Exported: {table_name} -> {csv_path} ({len(rows)} rows)")

    return csv_path, len(rows)


def export_database(db_path, output_dir, tables=None, quiet=False):
    """
    Export SQLite database to CSV files.

    Args:
        db_path: Path to SQLite database file
        output_dir: Directory to write CSV files
        tables: List of table names to export (None = all tables)
        quiet: Suppress verbose output

    Returns:
        dict with 'success', 'tables_exported', 'total_rows', 'csv_files'
    """
    if not os.path.isfile(db_path):
        raise FileNotFoundError(
            f"Database file not found: {db_path}\n"
            "Hint: Run 'adb pull /data/data/org.catatan_keuangan.catatan_keuangan/databases/keuangan.db .' "
            "from an Android device/emulator, or specify --db-path."
        )

    # Try to open as regular file first
    try:
        conn = sqlite3.connect(db_path)
    except sqlite3.OperationalError as e:
        # On Windows/Android subsystem, try with URI mode
        try:
            conn = sqlite3.connect(f"file:{db_path}", uri=True)
        except sqlite3.OperationalError:
            raise FileNotFoundError(
                f"Cannot open database: {db_path}\n{e}"
            )

    os.makedirs(output_dir, exist_ok=True)

    if not quiet:
        print(f"Connected to database: {db_path}")
        print(f"Output directory: {output_dir}")

    all_tables = get_tables(conn)
    if not quiet:
        print(f"Found tables: {', '.join(all_tables)}")

    target_tables = [t.strip() for t in tables] if tables else all_tables

    # Validate tables
    missing = set(target_tables) - set(all_tables)
    if missing:
        if not quiet:
            print(f"Warning: Tables not found in database: {', '.join(missing)}")
        target_tables = [t for t in target_tables if t in all_tables]

    if not target_tables:
        conn.close()
        raise ValueError("No valid tables to export.")

    csv_files = []
    total_rows = 0

    for table in target_tables:
        path, row_count = export_table_to_csv(conn, table, output_dir, quiet)
        csv_files.append(path)
        total_rows += row_count

    conn.close()

    if not quiet:
        print(f"\nExport complete: {len(csv_files)} tables, {total_rows} total rows")

    return {
        "success": True,
        "tables_exported": len(csv_files),
        "total_rows": total_rows,
        "csv_files": csv_files,
    }


def main():
    args = parse_args()

    output_dir = args.output_dir or os.path.join(os.getcwd(), "csv_export")
    db_path = find_database(args.db_path, args.android)

    tables = None
    if args.tables:
        tables = [t.strip() for t in args.tables.split(",")]

    try:
        result = export_database(
            db_path=db_path,
            output_dir=output_dir,
            tables=tables,
            quiet=args.quiet,
        )
        return 0
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
