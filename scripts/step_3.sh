#!/bin/bash
echo Preparing summary template
echo --------------------------
robot -d $RESULTS_DIR/step_3/ $TASKS_DIR/summary_template.robot
if [ -f "$DIR/reports/DTEK2040_assessment_summary.xlsx" ]
then
    echo Summary template OK.
    exit 0
else
    echo Initiating summary template failed!
    exit 1
fi