#!/bin/bash
START_PREPROCESSING=$(date +%s)

INDIR=${1}
INFILE=${2}
OUTDIR=${3}

echo ""
echo ""
echo "Welcome to the WDGPH CCEPYA report generator..."
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
echo "Separating files by childcare centre"
echo ""
echo "" 

# Creating a directory for childcare centres 
mkdir -p "${OUTDIR}/by_childcare_centre"

echo ""
echo ""
echo "Created directory ${OUTDIR}/by_childcare_centre"
echo ""
echo ""
echo "${INDIR}/${INFILE%.xlsx}.csv"


# Tell awk what delimiter to use, preserve headers, store header in variable called header 
# Process the  CSV file to separate by childcare centre in python
python separate_by_col.py "${INDIR}/${INFILE%.xlsx}.csv" "School/ Daycare ID" "${OUTDIR}/by_childcare_centre"

# echo ""
# echo ""
# echo "Generating a list of childcare centres that appear in the file for further processing"
# echo ""
# echo ""

# awk -F';' '{print $2}' ${INDIR}/data.csv | sort | uniq > "${OUTDIR}/childcare_centres_list.txt"

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
for file in "${OUTDIR}/by_childcare_centre/"*.csv
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
    echo "Processing: $i"
    python prep_data.py "${OUTDIR}/batched/$i" "../config/parameters.yaml" "../config/disease_map.json" "../input/vaccine_reference.json" "${OUTDIR}/english_json"
done

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
        ./generate_template_cceya.sh ${OUTDIR}/english_json "$filename" "../../templates/assets/logo.svg" "../../templates/assets/20250611_MatthewTenenbaum_Signature.jpg" "../../config/parameters.yaml"
    else
        echo "No JSON files found in ${OUTDIR}/english_json."
    fi
done

END_TEMPLATE_GENERATION=$(date +%s)
DIFF=$(( $END_TEMPLATE_GENERATION - $START_TEMPLATE_GENERATION ))
echo "Template generation complete for English data. Total time taken: $DIFF seconds"

START_TEMPLATE_COMPILATION=$(date +%s)

for typfile in ${OUTDIR}/english_json/*.typ
do
    if [ -f "$typfile" ]; then
        filename=$(basename "$typfile" .typ)
        echo "Compiling template for $filename"
        typst compile --font-path ./usr/share/fonts/truetype/freefont/ --root ../ ../output/english_json/"$filename".typ
    else
        echo "No Typst files found in ${OUTDIR}/english_json."
    fi
done


END_TEMPLATE_GENERATION=$(date +%s)
DIFF=$(( $END_TEMPLATE_GENERATION - $START_TEMPLATE_COMPILATION ))
echo "Template compilation complete for English data. Total time taken: $DIFF seconds"

echo ""
echo ""
echo "Clean-up files"
echo ""
echo "" 

rm -r ${OUTDIR}/by_language/
rm -r ${OUTDIR}/by_school/
rm -r ${OUTDIR}/batched/
rm -r ${OUTDIR}/english_json/*.typ
# rm -r ${OUTDIR}/french_json/*.typ
rm -r ${OUTDIR}/english_json/*.json
# rm -r ${OUTDIR}/french_json/*.json
rm -r ${OUTDIR}/english_json/*.csv
# rm -r ${OUTDIR}/french_json/*.csv