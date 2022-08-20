#!/bin/bash
summaryRowPos=${FIRST_ID_POSITION}
for sut in ${SUBJECTS_DIR}/* ; do
    # Run tests
    robot \
        --name  "$(basename "$sut") static tests" \
        -d $TESTS_DIR/../results/ex0/"$(basename "$sut")"/static/ \
        -i $TAG \
        -v TEST_SUBJECT_DIR:"$sut" \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        $TESTS_DIR/ex0-static-tests.robot

    # Update score
    robot \
        --name  "Update score for $(basename "$sut")" \
        -d $TESTS_DIR/../results/ex0/"$(basename "$sut")"/step_4/ \
        -i existing \
        -v STUDENT_OUTPUT:$TESTS_DIR/../results/ex0/"$(basename "$sut")"/static/output.xml \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        $TASKS_DIR/update_score.robot

    ((summaryRowPos=summaryRowPos+1))
done