#!/bin/bash
DIR=$(dirname "$0")
SUBMISSIONDIR="$(realpath "${DIR}/../data/submissions/")"
SUTDIR="$(realpath "${DIR}/../data/test-subjects/")"
ROBOTDIR="$(realpath "${DIR}/../tests/")"

echo ${SUBMISSIONDIR}
echo ${SUTDIR}
echo ${ROBOTDIR}

echo Extracting packaged submissions FROM data/submissions/ TO data/test-subjects/ ...

# Extracting zipped submissions
for package in ${SUBMISSIONDIR}/* ; do
  subject=$(echo "$(basename "$package")" | cut -f 1 -d '.')
  echo Processing ${subject} ...
  unzip -qo "${package}" -d ${SUTDIR}/"${subject}"/
done

echo All found packages extracted to data/test-subjects/ directory.

# Running assessment suite for each subject under test
echo Running assessments for extracted submissions ...
summaryRowPos=4
for sut in ${SUTDIR}/* ; do
  echo "$sut"
  robot \
    -d ${ROBOTDIR}/../results/"$sut"/ \
    -i ex0 \
    -v STUDENT_ID="$sut" \
    -v STUDENT_REPORT_ROW=${summaryRowPos} \
    ${ROBOTDIR}/assessment-cases.robot
    summaryRowPos=$((iteration+1))
done