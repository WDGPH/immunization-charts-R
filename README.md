# 🩺 Immunization Charts

## 📘 Introduction

This project provides a Python and bash-based workflow for generating personalized immunization history charts and notice letters for children who are overdue for mandated vaccinations under the **Immunization of School Pupils Act (ISPA)** or the **Child Care and Early Years Act (CCEYA)**. 
Reports are generated in PDF format using [Typst](https://typst.app) and a custom report template.

---

## ⚙️ Usage

### Environment 
This project is written in **bash** and **Python**, and uses [Typst](https://typst.app) for typesetting. 

All dependencies are managed via a `pyproject.toml` file. 

### Data
This project is intended to be used with data extracts from [Panorama PEAR](https://accessonehealth.ca/).

Input files, in `xlsx` format should be organized in a subfolder `input` (out of caution, input and output folders are `.gitignore`d, and need to be recreated by the user). Each `xlsx` file should be a single sheets. 

### Parameters 
The `parameters.yaml` file is specific to each run. 

The following can be modified based on the specifics of what should be included in the immunization reports: 

* output_folder: name of the output folder which will be updated dynamically in the script
* expected_columns: columns that ar eexpected in the input file
* chart_diseases: vaccines or agents that should occur in the template for the chart
* ignore_agents: vaccines or agents to ignore in/drop from immunization history
* delivery_date: date at time of mail delivery. This is used to calculate the student age at the time of mail delivery. Letters for students under 16 should be addressed to their parent/guardian
* data_date: to include in notice text as date that immunization history is reflective of
* min_rows: minimum number of rows to show in immunization history chart
* batch_size: number of clients to include in a single PDF

### Functionality 
Functionality remains a work in progress but this is how things work so far...

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