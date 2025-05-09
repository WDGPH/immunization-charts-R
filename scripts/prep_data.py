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

for index, row in df.iterrows():

    # Replace vaccines due with common name found in disease map 
    vaccines_due_updated = []
    for vaccine in row.Vaccines_Due.split(','):
        vax_to_compare = vaccine.strip()
        mapped = disease_map.get(vax_to_compare, vax_to_compare)
        vaccines_due_updated.append(mapped)
    
    # Replace col based on mapped values 
    # First convert it into a string
    # FIXME - should there be a comma after the last disease? 
    vaccines_due_str = ', '.join(str(e) for e in vaccines_due_updated)
    df.at[index, 'Vaccines_Due'] = vaccines_due_str

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

#print(structured_entries)