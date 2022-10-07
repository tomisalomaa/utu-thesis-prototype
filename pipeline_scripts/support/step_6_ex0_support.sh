#!/bin/bash
# Run tests
robot \
    --name  "$(basename "$sut") dynamic tests" \
    -d $RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/dynamic/ \
    -i $ASSESSMENT_EX \
    -v TEST_SUBJECT_DIR:"$sut" \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v STUDENT_REPORT_ROW:${summaryRowPos} \
    -v LIBRARIES_DIR:"$LIBRARIES_DIR" \
    -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
    -v RESOURCES_DIR:"$RESOURCES_DIR" \
    $TESTS_DIR/"$ASSESSMENT_EX"-dynamic-tests.robot

# Update score
robot \
    --name  "Update score for $(basename "$sut")" \
    -d $RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/step_6/ \
    -i existing \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v STUDENT_OUTPUT:$RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/dynamic/output.xml \
    -v STUDENT_REPORT_ROW:${summaryRowPos} \
    -v EX_NUM:"$ASSESSMENT_EX" \
    -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
    -v RESOURCES_DIR:"$RESOURCES_DIR" \
    -v REPORTS_DIR:"$REPORTS_DIR" \
    $TASKS_DIR/update_score.robot