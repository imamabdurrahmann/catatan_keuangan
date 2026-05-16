#!/usr/bin/env python3
"""
Export SQLite database from catatan_keuangan Flutter app to CSV files.

Usage:
    python export_db_to_csv.py [--db-path PATH] [--output-dir DIR]

Arguments:
    --db-path      Path to SQLite database file (keuangan.db).
                   If not provided, searches common locations.
    --output-dir   Output directory for CSV files. Defaults to 'exports'.
    --tables       Comma-separated list of tables to export.
                   Defaults to all tables: transaksi,dompet,budget,kategori,pengaturan
    -h, --help     Show this help message.

Examples:
    python export_db_to_csv.py
    python export_db_to_csv.py --db-path /path/to/keuangan.db --output-dir ./csv_exports
    python export_db_to_csv.py --tables transaksi,dompet
"""

import argparse
import csv
import os
import sqlite3
import sys
from pathlib import Path
from datetime import datetime

# Default database filename
DB_FILENAME = "keuangan.db"

# Common locations to search for the database file
SEARCH_PATHS = [
    # Current working directory
    Path.cwd(),
    # User home directory
    Path.home(),
    # Android emulator default sqflite path
    Path("/data/data/com.example.catatan_keuangan/databases"),
    Path("/data/data/com.example.catatan_keuangan/databases/"),
    # Linux desktop default
    Path.home() / ".local" / "share" / "catatan_keuangan",
    # macOS
    Path.home() / "Library" / "Application Support" / "catatan_keuangan",
    # Windows (if running as a sidecar)
    Path(os.environ.get("LOCALAPPDATA", "")) / "catatan_keuangan",
]

ALL_TABLES = ["transaksi", "dompet", "budget", "kategori", "pengaturan"]


def find_database(db_path: str | None) -> Path | None:
    """Find the database file from a path or search common locations."""
    if db_path:
        p = Path(db_path)
        if p.exists():
            return p
        # Try relative to cwd
        p2 = Path.cwd() / db_path
        if p2.exists():
            return p2
        print(f"Warning: Database file not found at '{db_path}'", file=sys.stderr)
        return None

    # Search common locations
    for search_dir in SEARCH_PATHS:
        candidate = search_dir / DB_FILENAME
        if candidate.exists():
            return candidate
        # Also check inside a 'databases' subdirectory
        candidate2 = search_dir / "databases" / DB_FILENAME
        if candidate2.exists():
            return candidate2

    return None


def escape_csv_value(value) -> str:
    """Escape a value for CSV output."""
    if value is None:
        return ""
    s = str(value)
    if any(c in s for c in (',', '"', '\n', '\r')):
        return '"' + s.replace('"', '""') + '"'
    return s


def export_table_to_csv(conn: sqlite3.Connection, table_name: str, output_path: Path) -> int:
    """Export a single database table to a CSV file. Returns row count."""
    cursor = conn.cursor()

    try:
        # Get all rows from the table
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()

        # Get column names from the table schema
        cursor.execute(f"PRAGMA table_info({table_name})")
        columns = [row[1] for row in cursor.fetchall()]

        if not columns:
            print(f"  Warning: Could not determine columns for table '{table_name}', skipping.", file=sys.stderr)
            return 0

        # Write CSV
        with open(output_path, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.writer(csvfile, quoting=csv.QUOTE_MINIMAL)
            writer.writerow(columns)
            for row in rows:
                writer.writerow([escape_csv_value(v) for v in row])

        return len(rows)

    except sqlite3.Error as e:
        print(f"  Error exporting table '{table_name}': {e}", file=sys.stderr)
        return 0
    finally:
        cursor.close()


def main():
    parser = argparse.ArgumentParser(
        description="Export SQLite database from catatan_keuangan app to CSV files.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--db-path",
        type=str,
        default=None,
        help="Path to SQLite database file (keuangan.db).",
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default="exports",
        help="Output directory for CSV files (default: exports/).",
    )
    parser.add_argument(
        "--tables",
        type=str,
        default=",".join(ALL_TABLES),
        help=f"Comma-separated tables to export (default: {','.join(ALL_TABLES)}).",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing CSV files without prompting.",
    )

    args = parser.parse_args()

    # Parse tables
    tables_to_export = [t.strip() for t in args.tables.split(",") if t.strip()]
    if not tables_to_export:
        print("Error: No tables specified for export.", file=sys.stderr)
        sys.exit(1)

    # Validate tables
    unknown_tables = set(tables_to_export) - set(ALL_TABLES)
    if unknown_tables:
        print(f"Warning: Unknown tables: {', '.join(unknown_tables)}. Available: {', '.join(ALL_TABLES)}", file=sys.stderr)

    # Find database
    db_path = find_database(args.db_path)
    if db_path is None:
        print(f"Error: Could not find database file '{DB_FILENAME}'.", file=sys.stderr)
        print("Please specify the database path with --db-path.", file=sys.stderr)
        sys.exit(1)

    print(f"Found database: {db_path}")

    # Connect to database
    try:
        conn = sqlite3.connect(str(db_path))
    except sqlite3.Error as e:
        print(f"Error connecting to database: {e}", file=sys.stderr)
        sys.exit(1)

    # Verify tables exist
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    existing_tables = set(row[0] for row in cursor.fetchall())
    cursor.close()

    tables_to_export = [t for t in tables_to_export if t in existing_tables]
    if not tables_to_export:
        print(f"Error: None of the specified tables exist in the database.", file=sys.stderr)
        conn.close()
        sys.exit(1)

    # Setup output directory
    output_dir = Path(args.output_dir)
    if not output_dir.is_absolute():
        output_dir = Path.cwd() / output_dir

    output_dir.mkdir(parents=True, exist_ok=True)

    # Check for existing files
    existing_files = [t for t in tables_to_export if (output_dir / f"{t}.csv").exists()]
    if existing_files and not args.overwrite:
        print(f"\nThe following CSV files already exist in '{output_dir}':")
        for t in existing_files:
            print(f"  - {t}.csv")
        response = input("Overwrite? [y/N]: ").strip().lower()
        if response != "y":
            print("Aborted.")
            conn.close()
            sys.exit(0)

    # Export each table
    print(f"\nExporting to: {output_dir}")
    print(f"Tables: {', '.join(tables_to_export)}\n")

    total_rows = 0
    for table in tables_to_export:
        csv_path = output_dir / f"{table}.csv"
        count = export_table_to_csv(conn, table, csv_path)
        print(f"  {table}: {count} rows -> {csv_path}")
        total_rows += count

    conn.close()

    print(f"\nDone. Exported {total_rows} total rows across {len(tables_to_export)} tables.")
    print(f"Output directory: {output_dir}")


if __name__ == "__main__":
    main()
