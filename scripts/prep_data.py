import pandas as pd
import sys
import re
from datetime import date
from utils import calculate_age
import yaml
import json

# Read vaccination file
path_vax = sys.argv[1]
df = pd.read_csv(path_vax, sep = ";")

# Read yaml config file
path_config = sys.argv[2]
with open(path_config, 'r') as f:
    data = yaml.full_load(f)

# Read in disease map file 
path_disease_map = sys.argv[3]
with open (path_disease_map, 'r') as f:
    disease_map = json.load(f)

print(disease_map)

# Take info out of config file
expected_columns = data['expected_columns']
ignore_agents = data['ignore_agents']

# Conduct checks of the data using yaml file...
# Check to see if the expected columns in the df match what is in the yaml
if expected_columns != list(df.columns):
    print(f"Column mismatch. \nExpected {expected_columns}.\nFound: {list(df.columns)}")
    sys.exit(1)

# Rename columns (remove spaces) for further processing...
df.columns = df.columns.str.replace(' ', '_')

structured_entries = []

for row in df.itertuples(index=True):

    matches = re.findall(r'\w{3} \d{1,2}, \d{4} - [^,]+', row.Received_Agents)
    
    for match in matches:
        date_str, vaccine = match.split(' - ')

        # Remove vaccines or agents that appear in the yaml/config file
        if vaccine in list(ignore_agents):
            break
        else:
            structured_entries.append({
                'date': date_str.strip(),
                'vaccine': vaccine.strip(),
                'client_id': row.Client_ID,
                'date_of_birth':row.Date_of_Birth,
                'age':calculate_age(row.Date_of_Birth, date_str)
            })

print(structured_entries)