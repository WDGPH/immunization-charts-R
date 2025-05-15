"""
Script name: prep_data.py
Description: This script prepares the data for the immunization notice template. It reads in a vaccination file, a config file, and a disease map file. It checks the data for expected columns, processes the data, and outputs a structured dictionary of client information and vaccination records.

Author: Kassy Raymond
Created: 2025-05-15
Last modified: 2025-05-15

Usage: python prep_data.py <vaccination_file> <config_file> <disease_map_file> <vaccine_reference_file>
Input:
    - vaccination_file: CSV file containing client vaccination data with columns such as Client_ID, First_Name, Last_Name, Date_of_Birth, Street_Address, City, Postal_Code, Province, Vaccines_Due, Received_Agents.
    - config_file: YAML file containing configuration settings such as expected columns, ignore agents, delivery date, and data date.
    - disease_map_file: JSON file mapping disease names to common names.
    - vaccine_reference_file: JSON file mapping vaccine names to disease names.
"""

# =============================================================================
# IMPORTS
# =============================================================================

import pandas as pd
import sys
import re
from utils import calculate_age, over_16_check
import yaml
import json
from collections import defaultdict
import os

# =============================================================================
# SYSTEM ARGUMENT CHECKS
# =============================================================================

# Check to see if correct number of system arguments   
if len(sys.argv) != 6:
    print("Usage: python prep_data.py <client_vaccination_file> <config_file> <disease_map_file> <vaccine_reference_file> <outdir>")
    sys.exit(1)

# Check to see if the client vaccination file exists
if not os.path.isfile(sys.argv[1]):
    print(f"Vaccination file {sys.argv[1]} does not exist.")
    sys.exit(1)

# Check to see if the config file exists
if not os.path.isfile(sys.argv[2]):
    print(f"Config file {sys.argv[2]} does not exist.")
    sys.exit(1)

# Check to see if the disease map file exists
if not os.path.isfile(sys.argv[3]):
    print(f"Disease map file {sys.argv[3]} does not exist.")
    sys.exit(1)

# Check to see if the vaccine reference file exists
if not os.path.isfile(sys.argv[4]):
    print(f"Vaccine reference file {sys.argv[4]} does not exist.")
    sys.exit(1)

# Check to see if the output directory exists
if not os.path.exists(sys.argv[5]):
    print(f"Output directory {sys.argv[5]} does not exist.")
    sys.exit(1)

# =============================================================================
# READ IN DATA
# =============================================================================

# Read client vaccination file
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

# Read in vaccine reference file
path_vaccine_ref = sys.argv[4]
with open (path_vaccine_ref, 'r') as f:
    vaccine_ref = json.load(f)

# Read in output directory
outdir = sys.argv[5]

# =============================================================================
# DATA CHECKS
# =============================================================================

# Conduct checks of the data using yaml file...
# Check to see if the expected columns in the df match what is in the yaml
expected_columns = data['expected_columns']
if expected_columns != list(df.columns):
    print(f"Column mismatch. \nExpected {expected_columns}.\nFound: {list(df.columns)}")
    sys.exit(1)

# =============================================================================
# DATA PROCESSING AND TRANSFORMATION
# =============================================================================

# Rename columns (remove spaces) for further processing...
df.columns = df.columns.str.replace(' ', '_')

# Take info out of config file
ignore_agents = data['ignore_agents']
delivery_date = data['delivery_date']
data_date = data['data_date']

# Create default dictionary for restructuring data
notices = defaultdict(lambda: {
    "name": "",
    "school": "",
    "date_of_birth": "",
    "age": "",
    "over_16": "",
    "vaccines_due": "",
    "recieved": []
})

# Create a list to hold structured entries for the received agents
structured_entries = []

# Loop through the dataframe and process each row
for index, row in df.iterrows():

    # Replace vaccines due with common name found in disease map 
    vaccines_due_updated = []
    for vaccine in row.Vaccines_Due.split(','):
        vax_to_compare = vaccine.strip()
        mapped = disease_map.get(vax_to_compare, vax_to_compare)
        vaccines_due_updated.append(mapped)
    
    # Replace col based on mapped values 
    # First convert it into a string
    vaccines_due_str = ', '.join(str(e) for e in vaccines_due_updated)

    # Check if the client is over 16 years old
    over_16 = over_16_check(row.Date_of_Birth, delivery_date)

    # Store the client ID in the notices dictionary 
    client_id = row.Client_ID

    # Store the client information in the notices dictionary
    notices[client_id]["name"] = row.First_Name + " " + row.Last_Name
    notices[client_id]["school"] = row.School
    notices[client_id]["date_of_birth"] = row.Date_of_Birth
    notices[client_id]["address"] = row.Street_Address
    notices[client_id]["city"] = row.City
    notices[client_id]["postal_code"] = row.Postal_Code
    notices[client_id]["province"] = row.Province
    notices[client_id]["over_16"] = over_16
    notices[client_id]["age"] = calculate_age(row.Date_of_Birth, "Apr 8, 2025")
    notices[client_id]["vaccines_due"] = vaccines_due_str.rstrip(", ")

    matches = re.findall(r'\w{3} \d{1,2}, \d{4} - [^,]+', row.Received_Agents)
    
    for match in matches:
        date_str, vaccine = match.split(' - ')

        # Remove vaccines or agents that appear in the yaml/config file
        if vaccine in list(ignore_agents):
            break
        else:
            # Create a list of diseases that the client has recieved using the vaccine referene json file.
            diseases = vaccine_ref.get(vaccine, vaccine)

            structured_entries.append({
                'date_given': date_str.strip(),
                'vaccine': vaccine.strip(),
                'age':calculate_age(row.Date_of_Birth, date_str),
                'diseases': diseases
            })
            # Append the structured entry to the client's received list
            notices[client_id]["recieved"].append(structured_entries[-1])

# =============================================================================
# OUTPUT
# =============================================================================

# Convert the defaultdict to a regular dictionary for easier handling
notices = dict(notices)

# Save the structured data to a JSON file
filename = os.path.basename(path_vax)[:-4]
output_path = outdir + '/' + filename + "_structured.json"
with open(output_path, 'w') as f:
    json.dump(notices, f, indent=4)
print(f"Structured data saved to {output_path}")