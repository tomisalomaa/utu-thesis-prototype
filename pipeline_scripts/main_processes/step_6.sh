#!/bin/bash
echo Executing dynamic tests
echo -----------------------
summaryRowPos=$FIRST_ID_POSITION
export REACT_PROJ_DIR
export REACT_BASE_DIR
export RESOURCES_DIR
export ASSESSMENT_EX
for sut in $SUBJECTS_DIR/* ; do
    export sut
    export summaryRowPos
    if [ "$ASSESSMENT_EX" == "ex0" ]
    then
        $SUPPORT_SCRIPT_DIR/step_6_ex0_support.sh
    elif [ "$ASSESSMENT_EX" == "ex1" ]
    then
        export et=e1t1
        $SUPPORT_SCRIPT_DIR/step_6_ex1_support.sh
        export et=e1t2
        $SUPPORT_SCRIPT_DIR/step_6_ex1_support.sh
    elif [ "$ASSESSMENT_EX" == "ex2" ]
    then
        pkill -f node
        # Move submitted project files for npm dev server
        robot \
            -i "$et" \
            -d $RESULTS_DIR/"$ASSESSMENT_EX"/step_6/ex2_support_step/"$(basename "$sut")"/ \
            -v STUDENT_ID:"$(basename "$sut")" \
            -v EX_NUM:"$ASSESSMENT_EX" \
            -v DYNA_DIR:"$REACT_PROJ_DIR" \
            -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
            -v RESOURCES_DIR:"$RESOURCES_DIR" \
            -v REPORTS_DIR:"$REPORTS_DIR" \
            -v TEST_SUBJECT_DIR:"$sut" \
            -v LIBRARIES_DIR:"$LIBRARIES_DIR" \
            $TASKS_DIR/support_tasks.robot
        $SUPPORT_SCRIPT_DIR/npm_start.sh $REACT_PROJ_DIR $REACT_BASE_DIR false
        export et=e2t1
        $SUPPORT_SCRIPT_DIR/step_6_ex2_support.sh
        export et=e2t2
        $SUPPORT_SCRIPT_DIR/step_6_ex2_support.sh
    elif [ "$ASSESSMENT_EX" == "ex3" ]
    then
        pkill -f node
        # Move project files for npm dev server
        robot \
            -i "$et" \
            -d $RESULTS_DIR/"$ASSESSMENT_EX"/step_6/ex3_support_step/"$(basename "$sut")"/ \
            -v STUDENT_ID:"$(basename "$sut")" \
            -v EX_NUM:"$ASSESSMENT_EX" \
            -v DYNA_DIR:"$REACT_PROJ_DIR" \
            -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
            -v RESOURCES_DIR:"$RESOURCES_DIR" \
            -v REPORTS_DIR:"$REPORTS_DIR" \
            -v TEST_SUBJECT_DIR:"$sut" \
            -v LIBRARIES_DIR:"$LIBRARIES_DIR" \
            $TASKS_DIR/support_tasks.robot
        # Build and start run
        cd $DIR
        $SUPPORT_SCRIPT_DIR/npm_run.sh $REACT_PROJ_DIR
        export et=e3t1
        $SUPPORT_SCRIPT_DIR/step_6_ex3_support.sh
    fi
    ((summaryRowPos=summaryRowPos+1))
done
if [ "$ASSESSMENT_EX" != "ex0" ]
then
    # Kill node
    echo Killing node processes...
    pkill -f node
    echo Done!
    echo Removing node directory...
    rm -r "$REACT_PROJ_DIR"
    echo Done!
fi
exit 0