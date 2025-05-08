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
echo "Separating English records into batches of 100"
echo ""
echo ""




echo ""
echo ""
echo "Separating French records into batches of 100"
echo ""
echo ""