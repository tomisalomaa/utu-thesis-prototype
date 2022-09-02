#!/bin/bash
echo Preparing summary template
echo --------------------------
robot -d $RESULTS_DIR/"$ASSESSMENT_EX"/step_3/ \
    -i "$ASSESSMENT_EX" \
    -v  EX_NUM:"$ASSESSMENT_EX" \
    $TASKS_DIR/summary_template.robot
if [ -f "$DIR/reports/"$ASSESSMENT_EX"/DTEK2040_assessment_summary.xlsx" ]
then
    summaryRowPos=${FIRST_ID_POSITION}
    for sut in ${SUBJECTS_DIR}/* ; do
        robot \
        --name  "Adding $(basename "$sut") to template..." \
        -d $TESTS_DIR/../results/"$ASSESSMENT_EX"/step_3/"$(basename "$sut")"/ \
        -i new \
        -v STUDENT_ID:"$(basename "$sut")" \
        -v STUDENT_REPORT_ROW:${summaryRowPos} \
        -v EX_NUM:"$ASSESSMENT_EX" \
        $TASKS_DIR/update_score.robot
        ((summaryRowPos=summaryRowPos+1))
    done
    echo Summary template OK.
    exit 0
else
    echo Initiating summary template failed!
    exit 1
fi