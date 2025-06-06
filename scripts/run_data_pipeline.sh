#!/bin/bash
START_PREPROCESSING=$(date +%s)

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
    exit 1
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
echo "Generating a list of schools that appear in the file for further processing"
echo ""
echo ""

awk -F';' '{print $2}' ${INDIR}/anonymized_data_sample.csv | sort | uniq > "${OUTDIR}/schools_list.txt"

echo ""
echo ""
echo "Separating files by language"
echo ""
echo ""

mkdir -p "${OUTDIR}/by_language"

echo ""
echo ""
echo "Created directory ${OUTDIR}/by_language"
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
        file = "'${OUTDIR}'/by_language/" lang "_" basefile ".csv";
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
echo "Pulling batch size from yaml file"
echo ""
echo ""

batch_size=$(grep '^batch_size:' ../config/parameters.yaml | awk '{print $2}')
echo ""
echo ""
echo "Separating csv files according to batch size: $batch_size"
echo ""
echo ""

echo ""
echo ""
echo "Storing files in batched directory"
echo ""
echo ""

mkdir -p "${OUTDIR}/batched"

# For each CSV in the input directory
for file in "${OUTDIR}/by_language/"*.csv
do
    filename=$(basename "$file" .csv)
    header=$(head -n 1 "$file")

    awk -v header="$header" -v batch_size="$batch_size" -v outdir="${OUTDIR}/batched" -v base="$filename" '
    NR > 1 {
        file_idx = int((NR-2)/batch_size) + 1
        file = sprintf("%s/%s_%02d.csv", outdir, base, file_idx)
        if (!(file in seen)) {
            print header > file
            seen[file] = 1
        }
        print >> file
    }
    ' "$file"

done

echo ""
echo ""
echo "Processing and transforming ENGLISH data from csv to structure json..."
echo ""
echo ""

mkdir -p "${OUTDIR}/english_json"
echo "" 
echo ""
echo "Created directory ${OUTDIR}/english_json"
echo ""
echo ""

for i in `ls ${OUTDIR}/batched/`
do
    if [[ $i == *"English"* ]]; then
        echo "Processing: $i"
    python prep_data.py "${OUTDIR}/batched/$i" "../config/parameters.yaml" "../config/disease_map.json" "../input/vaccine_reference.json" "${OUTDIR}/english_json"
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
        python prep_data.py "${OUTDIR}/batched/$i" "../config/parameters.yaml" "../config/disease_map.json" "../input/vaccine_reference.json" "${OUTDIR}/french_json"
    fi
done

echo ""
echo ""
echo "Data processing complete. The json files are located in the ${OUTDIR}/english_json and ${OUTDIR}/french_json directories."
echo ""
echo ""

END_PREPROCESSING=$(date +%s)
DIFF=$(( $END_PREPROCESSING - $START_PREPROCESSING ))
echo "Data preprocessing complete. Total time taken: $DIFF seconds"

echo ""
echo ""
echo "Now generating the immunization notice templates..."
echo ""
echo ""

echo ""
echo ""
echo "Generating immunization notice templates for English data..."
echo ""
echo ""

echo ""
echo ""
echo "Getting list of json files in ${OUTDIR}/english_json"
echo ""
echo ""

START_TEMPLATE_GENERATION=$(date +%s)

for jsonfile in ${OUTDIR}/english_json/*.json
do
    if [ -f "$jsonfile" ]; then
        filename=$(basename "$jsonfile" .json)
        echo "Generating template for $filename"
        ./generate_template.sh ${OUTDIR}/english_json "$filename" "../../config/parameters.yaml" "../../templates/assets/logo.svg"
    else
        echo "No JSON files found in ${OUTDIR}/english_json."
    fi
done

END_TEMPLATE_GENERATION=$(date +%s)
DIFF=$(( $END_TEMPLATE_GENERATION - $START_TEMPLATE_GENERATION ))
echo "Template generation complete for English data. Total time taken: $DIFF seconds"

START_TEMPLATE_COMPILATION=$(date +%s)

typst compile --font-path ../templates/assets/ --root ../ ../output/english_json/English_Maple_Syrup_High_01_immunization_notice.typ

END_TEMPLATE_GENERATION=$(date +%s)
DIFF=$(( $END_TEMPLATE_GENERATION - $START_TEMPLATE_COMPILATION ))
echo "Template compilation complete for English data. Total time taken: $DIFF seconds"

# echo ""
# echo ""
# echo "Clean-up files"
# echo ""
# echo "" 

# rm -r ${OUTDIR}/by_language_school/