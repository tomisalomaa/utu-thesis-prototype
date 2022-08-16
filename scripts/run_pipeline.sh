#!/bin/bash
echo =========================
echo PREPARING TO RUN PIPELINE
echo =========================
# Set global directory variables
export SCRIPT_DIR="$(realpath $(dirname "$0"))"
export DIR="$(realpath "$PWD")"
echo Global variables set

# Run step 1: verify directory structure and submitted contents
echo ================
echo STARTING STEP 1
echo ================
$SCRIPT_DIR/step_1.sh
step_status=$?

# if step 1 ok, run step 2: prepare content
if [ $step_status -eq 0 ]
then
    # export project sub directories to own variables
    export SUBMISSION_DIR="$(realpath "$DIR/data/submissions")"
    export SUBJECTS_DIR="$(realpath "$DIR/data/test-subjects")"
    export LIBRARIES_DIR="$(realpath "$DIR/libraries")"
    export REPORTS_DIR="$(realpath "$DIR/reports")"
    export RESOURCES_DIR="$(realpath "$DIR/resources")"
    export RESULTS_DIR="$(realpath "$DIR/results")"
    export TESTS_DIR="$(realpath "$DIR/tests")"
    export TASKS_DIR="$(realpath "$DIR/tasks")"
    echo Global variables updated
    echo ================
    echo STARTING STEP 2
    echo ================
    $SCRIPT_DIR/step_2.sh
    step_status=$?
else
    echo Step 1 did not complete successfully, ending pipeline execution!
    exit 1
fi

# if step 2 ok, run step 3: prepare summary template
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 3
    echo ================
    $SCRIPT_DIR/step_3.sh
    step_status=$?
else
    echo Step 2 did not complete successfully, ending pipeline execution!
    exit 1
fi

# if step 3 ok, run step 4: static testing
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 4
    echo ================
    $SCRIPT_DIR/step_4.sh
    step_status=$?
else
    echo Step 3 did not complete successfully, ending pipeline execution!
    exit 1
fi

# if step 4 ok, run step 5: prepare dynamic testing
# for now this step has no real content,
# it is mainly meant for preparing the SPAs
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 5
    echo ================
    $SCRIPT_DIR/step_5.sh
    step_status=$?
else
    echo Step 4 did not complete successfully, ending pipeline execution!
    exit 1
fi

# if step 5 ok, run step 6: dynamic testing
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 6
    echo ================
    $SCRIPT_DIR/step_6.sh
    step_status=$?
else
    echo Step 5 did not complete successfully, ending pipeline execution!
    exit 1
fi

# if step 6 ok, run step 7: summary file wrap-up
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 7
    echo ================
    $SCRIPT_DIR/step_7.sh
    step_status=$?
else
    echo Step 6 did not complete successfully, ending pipeline execution!
    exit 1
fi

# if step 7 ok, run step 8: artifacts and clean up
if [ $step_status -eq 0 ]
then
    echo ================
    echo STARTING STEP 8
    echo ================
    $SCRIPT_DIR/step_8.sh
    step_status=$?
else
    echo Step 7 did not complete successfully, ending pipeline execution!
    exit 1
fi

if [ $step_status -eq 0 ]
then
    echo ====================
    echo PIPELINE FINISHED OK
    echo ====================
    exit 0
else
    echo Step 8 did not complete successfully, ending pipeline execution!
    exit 1
fi