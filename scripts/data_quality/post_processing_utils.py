import pandas as pd
import sys
import csv

def check_school_count(input_file, pdf_files):
    """
    Checks if the number of schools or childcare centres in the input file matches the number of PDF files produced.

    Args:
        input_file (str): Path to the input CSV file containing school or childcare centre data.
        pdf_files (list): List of paths to the generated PDF files.

    Returns:
        bool: True if counts match, False otherwise.
    """
    df = pd.read_csv(input_file)
    school_count = df['school_name'].nunique()  # Assuming 'school_name' is the column with school names
    pdf_count = len(pdf_files)

    if school_count != pdf_count:
        print(f"Mismatch: {school_count} schools found in input file, but {pdf_count} PDF files generated.")
        return False
    else:
        print(f"Match: {school_count} schools found in input file, and {pdf_count} PDF files generated.")
        return True