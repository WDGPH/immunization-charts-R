# 🩺 Immunization Charts

## 📘 Introduction

This project provides a Python-based workflow for generating personalized immunization history charts and notice letters for children who are overdue for mandated vaccinations under the **Immunization of School Pupils Act (ISPA)** or the **Child Care and Early Years Act (CCEYA)**. Reports are generated in PDF format using [Typst](https://typst.app) and a custom report template.

---

## ⚙️ Usage

### Environment 
This project is written in **Python** and uses [Typst](https://typst.app) for typesetting. All dependencies are managed via a `pyproject.toml` file. 

### Data
This project is intended to be used with data extracts from [Panorama PEAR](https://accessonehealth.ca/).

Input files, in `xlsx` format should be organized in a subfolder `input` (out of caution, input and output folders are `.gitignore`d, and need to be recreated by the user). Each `xlsx` file should be a single sheet with the following columns:
- `Language`
- `School`
- `Client ID`
- `First Name`
- `Last Name`
- `Date of Birth`
- `Street Address`
- `City`
- `Province`
- `Postal Code`
- `Vaccines Due`
- `Received Agents`

In case of large cohorts, it may be helpful to have `xlsx` exports from Panorama PEAR batched by client birth year. 

`Language` should be set to either `French` or `English` for each client.

`Received Agents` is a string representation of the immunization history. To create this immunization history string, a "Repeater" Data Container must be used in the Panorama PEAR report builder. The repeater will be formatted as:
1. `[PresentationView].[Immunization Received].[Date Administered]`
2. Text box with space, dash, and a space (` - `)
3. `[PresentationView].[Immunization Received].[Immunizing Agent]`

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
