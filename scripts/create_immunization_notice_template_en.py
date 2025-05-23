import sys
import json
import yaml
from datetime import datetime
import os

# Check to see if correct number of system arguments

# 

# Read yaml config file
path_config = sys.argv[1]
with open(path_config, 'r') as f:
    data = yaml.full_load(f)

# Create output folder
now = datetime.now()
today = now.strftime("%Y%m%d%H%M%S")
output_file_name = data['output_folder'] + today

try:
    os.mkdir("../output/%s" % output_file_name)
except OSError as error:
    print(error)


# Create the immunization notice template
