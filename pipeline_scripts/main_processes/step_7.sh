#!/bin/bash
echo Collecting summary scores
echo -------------------------
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
    current_ex_max_score=$EX3_MAX_SCORE
fi

for sut in ${SUBJECTS_DIR}/* ; do
    # Calculate total scores
    robot \
        --name  "Calculate total score for $(basename "$sut")" \
        -d $RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/step_7/ \
        -i total \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        -v MAX_SCORE:$current_ex_max_score \
        -v EX_NUM:"$ASSESSMENT_EX" \
        -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
        -v RESOURCES_DIR:"$RESOURCES_DIR" \
        -v REPORTS_DIR:"$REPORTS_DIR" \
        $TASKS_DIR/update_score.robot
    ((summaryRowPos=summaryRowPos+1))
done