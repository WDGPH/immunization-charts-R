import pandas as pd
import sys
import csv

def scan_csv_for_errors(csv_path):
    
    """
    Scans a CSV file for malformed rows that may cause parsing errors.

    Args:
        csv_path (str): The path to the CSV file to be scanned.

    The function reads the CSV file line by line and attempts to parse each row.
    If a row is malformed (e.g., due to unclosed quotes or other formatting issues),
    it prints the line number and the content of the problematic row.

    This utility helps identify problematic rows in a CSV file before processing
    with more strict parsers like pandas.
    """

    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter=',', quotechar='"')
        for i, row in enumerate(reader, start=1):
            try:
                # Try to join and re-parse the row to catch malformed lines
                csv.reader([','.join(row)], delimiter=',', quotechar='"')
            except Exception as e:
                print(f"Malformed row at line {i}: {e}")
                print(f"Row content: {row}")

    print("Scan complete.")

def scan_csv_for_quoting_issues(csv_path):
    """
    Scans a CSV file for lines with an odd number of quote characters,
    which may indicate quoting issues such as unclosed quotes.

    Args:
        csv_path (str): The path to the CSV file to be scanned.

    Prints the line number and content for any line with an odd number of quotes.
    """
    with open(csv_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f, start=1):
            quote_count = line.count('"')
            if quote_count % 2 != 0:
                print(f"Possible quoting issue at line {i} (odd number of quotes: {quote_count}):")
                print(line.rstrip())

    print("Quoting scan complete.")

if __name__ == "__main__":

    path_vax = sys.argv[1]
    scan_csv_for_errors(path_vax)
    scan_csv_for_quoting_issues(path_vax)