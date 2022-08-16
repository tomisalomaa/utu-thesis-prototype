#!/bin/bash
# ---------- make these arguments from main script
summaryRowPos=4
tag=full
# ----------
for sut in ${SUBJECTS_DIR}/* ; do
  echo "$(basename "$sut")"
  echo "$summaryRowPos"
  robot \
    --name  "$(basename "$sut") static tests" \
    -d ${TESTS_DIR}/../results/ex0/"$(basename "$sut")"/ \
    -i ${tag} \
    -v TEST_SUBJECT_DIR:"$sut" \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v STUDENT_REPORT_ROW:${summaryRowPos} \
    ${TESTS_DIR}/ex0-static-tests.robot
  ((summaryRowPos=summaryRowPos+1))
done