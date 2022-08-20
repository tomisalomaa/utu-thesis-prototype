#!/bin/bash
summaryRowPos=${FIRST_ID_POSITION}
for sut in ${SUBJECTS_DIR}/* ; do
    # Calculate total scores
    robot \
        --name  "Calculate total score for $(basename "$sut")" \
        -d $TESTS_DIR/../results/ex0/"$(basename "$sut")"/step_7/ \
        -i total \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        -v MAX_SCORE:${EX0_MAX_SCORE} \
        $TASKS_DIR/update_score.robot
    ((summaryRowPos=summaryRowPos+1))
done