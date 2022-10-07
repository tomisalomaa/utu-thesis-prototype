#!/bin/bash
start_time="$(date -u +%s)"
echo Pipeline started "$(date)"
echo =========================
echo PREPARING TO RUN PIPELINE
echo =========================
# Set global directory variables
export ASSESSMENT_EX="$1"
export DIR="$(realpath "$PWD")"
export SCRIPT_DIR="$DIR/pipeline_scripts"
export MAIN_SCRIPT_DIR="$DIR/pipeline_scripts/main_processes"
export SUPPORT_SCRIPT_DIR="$DIR/pipeline_scripts/support"
# for docker implementation use /opt/; for local use whatever, for example /home/
export REACT_BASE_DIR="/opt/"
export REACT_PROJ_DIR="/opt/system-under-test/"
echo "Global variables set."

# Run step 1: verify directory structure and submitted contents
echo ================
echo STARTING STEP 1
echo ================
$MAIN_SCRIPT_DIR/step_1.sh
step_status=$?

# if step 1 ok, run step 2: prepare content
if [ $step_status -eq 0 ]
then
    # export project sub directories to own variables
    export SUBMISSION_DIR="$(realpath "$DIR/data/submissions/$ASSESSMENT_EX")"
    export SUBJECTS_DIR="$(realpath "$DIR/data/test-subjects")"
    export LIBRARIES_DIR="$(realpath "$DIR/libraries")"
    export GLOBAL_ROBO_VARIABLES_DIR="$(realpath "$DIR/variables")"
    export REPORTS_DIR="$(realpath "$DIR/reports")"
    export RESOURCES_DIR="$(realpath "$DIR/resources")"
    export RESULTS_DIR="$(realpath "$DIR/results")"
    export TESTS_DIR="$(realpath "$DIR/robot_scripts/tests")"
    export TASKS_DIR="$(realpath "$DIR/robot_scripts/tasks")"
    # export test scope tag for robot tests
    export TAG="full"
    # export report manipulation related params
    export FIRST_ID_POSITION=4
    # export exercise scoring params -- max score from programming tasks
    export EX0_MAX_SCORE=2
    export EX1_MAX_SCORE=10
    export EX2_MAX_SCORE=10
    export EX3_MAX_SCORE=12

    echo Global variables updated
    step_one_time="$(date -u +%s)"
    echo ================
    echo STARTING STEP 2
    echo ================
    $MAIN_SCRIPT_DIR/step_2.sh
    step_status=$?
else
    echo Step 1 did not complete successfully, ending pipeline execution!
    exit 1
fi
step_two_time="$(date -u +%s)"
# if step 2 ok, run step 3: prepare summary template
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 3
    echo ================
    $MAIN_SCRIPT_DIR/step_3.sh
    step_status=$?
else
    echo Step 2 did not complete successfully, ending pipeline execution!
    exit 1
fi
step_three_time="$(date -u +%s)"
# if step 3 ok, run step 4: static testing
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 4
    echo ================
    $MAIN_SCRIPT_DIR/step_4.sh
    step_status=$?
else
    echo Step 3 did not complete successfully, ending pipeline execution!
    exit 1
fi
step_four_time="$(date -u +%s)"
# if step 4 ok, run step 5: prepare dynamic testing
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 5
    echo ================
    $MAIN_SCRIPT_DIR/step_5.sh
    step_status=$?
else
    echo Step 4 did not complete successfully, ending pipeline execution!
    exit 1
fi
step_five_time="$(date -u +%s)"
# if step 5 ok, run step 6: dynamic testing
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 6
    echo ================
    $MAIN_SCRIPT_DIR/step_6.sh
    step_status=$?
else
    echo Step 5 did not complete successfully, ending pipeline execution!
    exit 1
fi
step_six_time="$(date -u +%s)"
# if step 6 ok, run step 7: summary file wrap-up
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 7
    echo ================
    $MAIN_SCRIPT_DIR/step_7.sh
    step_status=$?
else
    echo Step 6 did not complete successfully, ending pipeline execution!
    exit 1
fi
step_seven_time="$(date -u +%s)"
# if step 7 ok, run step 8: artifacts and clean up
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 8
    echo ================
    $MAIN_SCRIPT_DIR/step_8.sh
    step_status=$?
else
    echo Step 7 did not complete successfully, ending pipeline execution!
    exit 1
fi
step_eight_time="$(date -u +%s)"
if [ $step_status -eq 0 ]
then
    echo ====================
    echo PIPELINE FINISHED OK
    echo ====================
    end_time="$(date -u +%s)"
    echo Pipeline finished "$(date)"
    echo Entire pipeline executed in: $((end_time-start_time)) seconds
    echo -e "===============================" >> run_logs.txt
    echo -e "PIPELINE FINISHED OK" >> run_logs.txt
    echo -e "$ASSESSMENT_EX EXECUTION TIMES:" >> run_logs.txt
    echo -e "TOTAL: $((end_time-start_time))" >> run_logs.txt
    echo -e "STATIC TESTS: $((step_four_time-step_three_time))" >> run_logs.txt
    echo -e "DYNAMIC TESTS: $((step_six_time-step_four_time))" >> run_logs.txt # this includes also the preparation in step 5
    echo -e "STEP 1: $((step_one_time-start_time))" >> run_logs.txt
    echo -e "STEP 2: $((step_two_time-start_time))" >> run_logs.txt
    echo -e "STEP 3: $((step_three_time-start_time))" >> run_logs.txt
    echo -e "STEP 4: $((step_four_time-start_time))" >> run_logs.txt
    echo -e "STEP 5: $((step_five_time-start_time))" >> run_logs.txt
    echo -e "STEP 6: $((step_six_time-start_time))" >> run_logs.txt
    echo -e "STEP 7: $((step_seven_time-start_time))" >> run_logs.txt
    echo -e "STEP 8: $((step_eight_time-start_time))" >> run_logs.txt
    echo -e "===============================" >> run_logs.txt
    exit 0
else
    echo Step 8 did not complete successfully, ending pipeline execution!
    exit 1
fi