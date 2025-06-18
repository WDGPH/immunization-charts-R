import pandas as pd
import sys

# Load in file
if len(sys.argv) != 4:
    print("Usage: python separate_by_col.py <file_path> <column_name> <output_path>")
    sys.exit(1)

file_path = sys.argv[1]
col_name = sys.argv[2] 
out_path = sys.argv[3] 

# Read the data from the specified file
data = pd.read_csv(file_path, sep=';')  # Use pd.read_excel() for Excel files

# Group data by daycare/school column
grouped = data.groupby(col_name)

# Save each group to a separate file
for name, group in grouped:
    # Remove spaces and other invalid characters from the file name
    safe_name = str(name).replace(" ", "_").replace("/", "_").replace("-","_")
    output_file = f"{out_path}/{safe_name}.csv"  # Save as CSV
    
    group.to_csv(output_file, index=False)
