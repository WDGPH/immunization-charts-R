# 🩺 Immunization Charts

## 📘 Introduction


This project provides a Python and bash-based workflow for generating **personalized immunization history charts** and **notice letters** for children who are overdue for mandated vaccinations under:

- **Immunization of School Pupils Act (ISPA)**
- **Child Care and Early Years Act (CCEYA)**

Reports are generated in PDF format using [Typst](https://typst.app) and a custom report template.

Currently, Wellington-Dufferin Guelph Public Health is using this workflow. Future work involves expanding the workflow to other Public Health Units (PHU), allowing for the automatic generation of reports beyond a single PHU. 

## ⚙️ Environment Set-Up

This project is written in **bash** and **Python**, and uses [Typst](https://typst.app) for typesetting. All python dependencies are managed via a `pyproject.toml` and `uv`. 

### Configuring the Virtual Environment 

To start the virtual environment:

```bash
uv venv
```

To activate the virtual environment: 

```bash
source .venv/bin/activate
```

## Input Data

This project is intended to be used with data extracts from [Panorama PEAR](https://accessonehealth.ca/).

* All input files should be placed in the `input/` subfolder. The input files are not tracked by Git. Should you clone or fork this repository, please ensure that the `input/` subfolder is tracked by your `.gitignore` file.
* Files must be in `.xlsx` format with a **single worksheet** per file

## Parameters 
The `parameters.yaml` file controls modifiable features of report generation. 

The following can be modified: 

| Parameter | Description |
| --------- | ----------- |
| output_folder | Name of the output folder which will be updated dynamically in the script | 
| expected_columns | Columns that are expected in the input file |
| chart_diseases | Vaccines or agents that should occur in the template for the chart | 
| ignore_agents | Vaccines or agents to ignore in/drop from immunization history |
| delivery_date | Date at time of mail delivery. This is used to calculate the student age at the time of mail delivery. Letters for students under 16 should be addressed to their parent/guardian |
| data_date | To include in notice text as date that immunization history is reflective of |
| min_rows | Minimum number of rows to show in immunization history chart |
| batch_size | Number of clients to include in a single PDF |

## Data Preprocessing Framework 

The development of this framework is currently **in progress**

Before generating the charts and letters, input data from Panorama is validated and cleaned. There are two major steps that this occurs in: 

1. Data Quality Checks:

`GreatExpectations`, a python package, is used to generate data quality reports. 

**Remainder to be added...**

2. Preprocessing Steps: 

* Column name mapping and dropping unneeded columns
* Drop all duplicate values 
* Normalize date fields, cases, and formats
* Calculate fields: age, over_16
* Check to see if calculated fields are as expected
* Output: full csv file of cleaned data

Details of data preprocessing steps are outlined below.

### Column Naming Mapping 

Different Panorama exports may use varying column names. This project includes a column mapping system to ensure that the column names are consistently mapped and can be used downstream in our data pipeline. We expect to have variability in column naming conventions as this project is expanded to other Public Health Units in the province.

The steps for column naming mapping are found below: 

1. All columns in the input file are collected and compared to a mapping file found in `config/column_map.yaml`
2. Any columns that do not have matches from our mapping file are logged for review.
3. Columns are manually reviewed and added to the mapping file. 

### Dropping Duplicate Rows

Duplicate rows are identified using the client_id field. Rows with duplicate client ids are dropped **if** the remaining fields in the sheet are also duplicated. 

If duplicate Client IDs are identified but the remaining fields are not consistent, these fields are flagged, removed from the master list, and retained in a log file for data quality reporting.

### Normalize Date Fields, Cases, and Formats

To ensure that all fields are consistent, each column is checked for consistent formatting. 

### Calculate Required Fields 

For report generation, we typically need two fields: 

1. `age`
2. `over_16`

The `age` field is calculated using the `date_of_birth` field, which is provided by the Panorama export. 

The `over_16` field is calculated using the `age` field. The resultant data type is a boolean. 

### Checking Required Fields

Once the required fields are generated, we have to check the output to ensure that it was generated as expected.

## Running the Pipeline

`run_data_pipeline.sh` runs the pipeline: 

It takes 3 arguments:
    1. The INDIR, or the directory that holds the input data
    2. The INFILE, or the excel file from Panorama
    3. The OUTDIR, or the name of the directory that will hold the output data.

For example: `./run_data_pipeline.sh ../input/ ../input/data_sample.xlsx ..output/`

The script: 
* Looks in the input directory for a vaccine_reference.xlsx file. If it is found, it checks to see if an equivalent json is available. If the equivalent json is not available, the script runs `convert_vaccine_reference.py`, generating a json script for processing later in the pipeline.
* Looks for the input file (the file that holds the client information from Panorama). If it cannot find the file, it throws an error and the script stops. If the file is found, `convert_excel_csv.py` converts the excel file to a csv file for further processing.
* Next, a directory is created in the specified output directory to hold the data once it is split by school.
* An `awk` script is ran to separate the file into schools, naming each output file according to school. 
* A directory is created in the specified output directory to hold the data once it is split by language (English or French).
* An `awk` script is ran to separate each school file by language, naming each output file according to school and language in the created directory.
* Data is then processed using the `prep_data.py` script. A json file is produced for each file in the `by_language_school` directory. New directories are created for the output json files for both English and French.
