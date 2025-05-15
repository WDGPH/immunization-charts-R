#!/bin/bash

INDIR=${1}
INFILE=${2}
OUTDIR=${3}

echo ""
echo ""
echo "Welcome to the WDGPH report generator..."
echo ""
echo ""

echo ""
echo ""
echo "Checking to see if the vaccine reference spreadsheet exists..."
echo ""
echo ""

if [ ! -f "${INDIR}/vaccine_reference.xlsx" ]
then
    echo "ERROR! File ${INDIR}/vaccine_reference.xlsx does not exist. Check your system arguments to ensure you are specifying the correct input directory. Check to ensure that the vaccine reference sheet exists and is in the correct directory."
fi

echo ""
echo ""
echo "If the vaccine reference json does not already exist we will convert the spreadsheet into json for further processing."
echo ""
echo ""

if [ ! -f "${INDIR}/vaccine_reference.json" ]
then 
    python convert_vaccine_reference.py
fi

echo ""
echo ""
echo " Checking to see if ${INDIR}/${INFILE} exists..."
echo "" 
echo "" 

if [ ! -f "${INDIR}/${INFILE}" ]
then
    echo "ERROR! File ${INDIR}/${INFILE} does not exist. Check your system arguments, the specified directory, and the file name."
    exit 1
fi 

echo ""
echo ""
echo "Converting ${INDIR}/${INFILE} to csv"
echo ""
echo ""

python convert_excel_csv.py ${INDIR}/${INFILE}

echo "" 
echo ""
echo "Separating files by school"
echo ""
echo "" 

# Creating a directory for schools 
mkdir -p "${OUTDIR}/by_school"

echo ""
echo ""
echo "Created directory ${OUTDIR}/by_school"
echo ""
echo ""

# Tell awk what delimiter to use, preserve headers, store header in variable called header 
awk -F';' '
BEGIN { OFS = ";" }
NR==1 {header = $0; next}
{
  gsub(/[^a-zA-Z0-9_-]/, "_", $2); # sanitize filename
  file = "'${OUTDIR}'/by_school/" $2 ".csv";
  if (!(file in seen)) {
    print header > file;
    seen[file];
  }
  print $0 >> file;
}' "${INDIR}/anonymized_data_sample.csv"

echo ""
echo ""
echo "Separating files by language"
echo ""
echo ""

mkdir -p "${OUTDIR}/by_language_school"

echo ""
echo ""
echo "Created directory ${OUTDIR}/by_language_school"
echo ""
echo ""

for i in `ls ${OUTDIR}/by_school/`
do
    echo ""
    echo "Separating ${i} by language"
    echo "" 
    for lang in "English" "French"
    do
        echo "Processing: $lang"
        awk -F';' -v lang="$lang" -v school="${i}" -v outdir="${OUTDIR}" '
        BEGIN {
            # Sanitize input filename (remove extension, clean up)
            split(school, parts, ".")
            base = parts[1]
            gsub(/[^a-zA-Z0-9_-]/, "_", base)
            basefile = base
        }
        NR==1 {header = $0; next}
        $1 == lang {
        file = "'${OUTDIR}'/by_language_school/" lang "_" basefile ".csv";
        if (!(file in seen)) {
            print header > file;
            seen[file]
        }
        print >> file;
        }' "${OUTDIR}/by_school/${i}"
    done
done

echo ""
echo ""
echo "Processing and transforming ENGLISH data from excel to structure json..."
echo ""
echo ""

mkdir -p "${OUTDIR}/english_json"
echo "" 
echo ""
echo "Created directory ${OUTDIR}/english_json"
echo ""
echo ""

for i in `ls ${OUTDIR}/by_language_school/`
do
    if [[ $i == *"English"* ]]; then
        echo "Processing: $i"
        python prep_data.py "${OUTDIR}/by_language_school/${i}" "../config/parameters.yaml" "../config/disease_map.json" "../input/vaccine_reference.json"
    fi
done

echo ""
echo ""
echo "Processing and transforming FRENCH data from excel to structure json..."
echo ""
echo ""

mkdir -p "${OUTDIR}/french_json"
echo ""
echo ""
echo "Created directory ${OUTDIR}/french_json"
echo ""
echo ""

for i in `ls ${OUTDIR}/by_language_school/`
do
    if [[ $i == *"French"* ]]; then
        echo "Processing: $i"
        python prep_data.py "${OUTDIR}/by_language_school/${i}" "../config/parameters.yaml" "../config/disease_map.json" "../input/vaccine_reference.json"
    fi
done

echo ""
echo ""
echo "Data processing complete. The json files are located in the ${OUTDIR}/english_json and ${OUTDIR}/french_json directories."
echo ""
echo ""