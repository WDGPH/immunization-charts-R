#!/bin/bash

INDIR=${1}
INFILE=${2}
OUTDIR=${3}

echo = ""
echo = ""
echo = "Welcome to the WDGPH report generator..."
echo = ""
echo = ""

# FIX ME: Check to see if input file exists

echo = "Converting ${INDIR}/${INFILE} to csv"
echo = ""
echo = ""

python convert_excel_csv.py ${INDIR}/${INFILE}

echo = "" 
echo = ""
echo = "Separating files by language"
echo = ""
echo = "" 

awk -F';' '{print > "../output/" $1 ".txt"}' ../input/anonymized_data_sample.csv

echo = ""
echo = ""
echo = "Separating files by school"
echo = ""
echo = ""

for i in "English" "French"
do
    echo $i
    awk -F';' '{print > "../output/"${i} "_" $2".txt"}' ../output/$i.txt
done