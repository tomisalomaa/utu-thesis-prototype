#!/bin/bash
# Move index file for npm dev server
robot \
    -i "$et" \
    -d $TESTS_DIR/../results/"$ASSESSMENT_EX"/step_6/ex1_support_step/"$(basename "$sut")"/ \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v EX_NUM:"$ASSESSMENT_EX" \
    -v DYNA_DIR:"$REACT_PROJ_DIR" \
    -v SUT_DIR:"$sut" \
    $TASKS_DIR/support_tasks.robot

# Run tests
robot \
    --name  "$(basename "$sut") dynamic tests" \
    -d $TESTS_DIR/../results/"$ASSESSMENT_EX"/"$(basename "$sut")"/dynamic/ \
    -i $et \
    -v TEST_SUBJECT_DIR:"$sut" \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v STUDENT_REPORT_ROW:${summaryRowPos} \
    -v REACT_APP_ADDR:"http://localhost:3000" \
    $TESTS_DIR/"$ASSESSMENT_EX"-dynamic-tests.robot

# Update score
robot \
    --name  "Update score for $(basename "$sut")" \
    -d $TESTS_DIR/../results/"$ASSESSMENT_EX"/"$(basename "$sut")"/step_6/ \
    -i existing \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v STUDENT_OUTPUT:$TESTS_DIR/../results/"$ASSESSMENT_EX"/"$(basename "$sut")"/dynamic/output.xml \
    -v STUDENT_REPORT_ROW:${summaryRowPos} \
    -v EX_NUM:"$ASSESSMENT_EX" \
    $TASKS_DIR/update_score.robot