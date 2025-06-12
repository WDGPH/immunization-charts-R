import pandas as pd
import sys

# Load in file
if len(sys.argv) != 4:
    print("Usage: python separate_by_col.py <file_path>")
    sys.exit(1)

file_path = sys.argv[1]
col_name = sys.argv[2] 
out_path = sys.argv[3] 

# Read the data from the specified file
data = pd.read_csv(file_path, sep=';')  # Use pd.read_excel() for Excel files

# Group data by daycare/school column
grouped = data.groupby(col_name)  # Replace 'Daycare/School' with the actual column name

# Save each group to a separate file
for name, group in grouped:
    output_file = f"{out_path}/{name}.csv"  # Save as CSV; change to .xlsx for Excel
    group.to_csv(output_file, index=False)
    print(f"Saved {output_file}")