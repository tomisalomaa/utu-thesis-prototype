#!/bin/bash
echo Executing static tests
echo ----------------------
summaryRowPos=${FIRST_ID_POSITION}
if [ "$ASSESSMENT_EX" == "ex0" ]
then
    current_ex_max_score=$EX0_MAX_SCORE
elif  [ "$ASSESSMENT_EX" == "ex1" ]
then
    current_ex_max_score=$EX1_MAX_SCORE
elif  [ "$ASSESSMENT_EX" == "ex2" ]
then
    current_ex_max_score=$EX2_MAX_SCORE
elif  [ "$ASSESSMENT_EX" == "ex3" ]
then
    echo No static tests created.
    echo Moving on to next step.
    exit 0
    # current_ex_max_score=$EX3_MAX_SCORE
fi

for sut in ${SUBJECTS_DIR}/* ; do
    # Run tests
    robot \
        --name  "$(basename "$sut") static tests" \
        -d $RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/static/ \
        -i $TAG \
        -v TEST_SUBJECT_DIR:"$sut" \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        -v LIBRARIES_DIR:"$LIBRARIES_DIR" \
        -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
        -v RESOURCES_DIR:"$RESOURCES_DIR" \
        $TESTS_DIR/"$ASSESSMENT_EX"-static-tests.robot

    # Update score
    robot \
        --name  "Update score for $(basename "$sut")" \
        -d $RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/step_4/ \
        -i existing \
        -v STUDENT_OUTPUT:$RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/static/output.xml \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        -v EX_NUM:"$ASSESSMENT_EX" \
        -v MAX_SCORE:"$current_ex_max_score" \
        -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
        -v RESOURCES_DIR:"$RESOURCES_DIR" \
        -v REPORTS_DIR:"$REPORTS_DIR" \
        $TASKS_DIR/update_score.robot

    ((summaryRowPos=summaryRowPos+1))
done