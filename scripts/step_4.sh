#!/bin/bash
echo Executing static tests
echo ----------------------
summaryRowPos=${FIRST_ID_POSITION}
for sut in ${SUBJECTS_DIR}/* ; do
    # Run tests
    robot \
        --name  "$(basename "$sut") static tests" \
        -d $TESTS_DIR/../results/"$ASSESSMENT_EX"/"$(basename "$sut")"/static/ \
        -i $TAG \
        -v TEST_SUBJECT_DIR:"$sut" \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        $TESTS_DIR/"$ASSESSMENT_EX"-static-tests.robot

    # Update score
    robot \
        --name  "Update score for $(basename "$sut")" \
        -d $TESTS_DIR/../results/"$ASSESSMENT_EX"/"$(basename "$sut")"/step_4/ \
        -i existing \
        -v STUDENT_OUTPUT:$TESTS_DIR/../results/"$ASSESSMENT_EX"/"$(basename "$sut")"/static/output.xml \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        -v EX_NUM:"$ASSESSMENT_EX" \
        $TASKS_DIR/update_score.robot

    ((summaryRowPos=summaryRowPos+1))
done