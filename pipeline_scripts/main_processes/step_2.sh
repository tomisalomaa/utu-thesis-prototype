#!/bin/bash
echo Extracting zipped submissions
echo -----------------------------
for package in $SUBMISSION_DIR/* ; do
    subject=$(echo "$(basename "$package")" | cut -f 1 -d '.')
    echo Processing $subject...
    unzip -qo "$package" -d $SUBJECTS_DIR/"$subject"
done
number_of_submissions=$(find "$SUBMISSION_DIR"/*.zip -maxdepth 0 -type f | wc -l)
number_of_extracted_submissions=$(find ./data/test-subjects/* -maxdepth 0 -type d | wc -l)
if [ $number_of_submissions -eq $number_of_extracted_submissions ]
then
    echo All submissions successfully extracted.
    exit 0
else
    echo Unable to extract all submissions!
    exit 1
fi