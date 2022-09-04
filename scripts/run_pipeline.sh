#!/bin/bash
echo =========================
echo PREPARING TO RUN PIPELINE
echo =========================
# Set global directory variables
export ASSESSMENT_EX="$1"
export SCRIPT_DIR="$(realpath $(dirname "$0"))"
export DIR="$(realpath "$PWD")"
# for docker implementation use /opt/; for local use for example /home/
export REACT_BASE_DIR="/opt/"
export REACT_PROJ_DIR="/opt/system-under-test/"
echo "Global variables set."

# Run step 1: verify directory structure and submitted contents
echo ================
echo STARTING STEP 1
echo ================
./scripts/step_1.sh
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
    # export test scope tag for robot tests
    export TAG="full"
    # export report manipulation related params
    export FIRST_ID_POSITION=4
    # export exercise scoring params -- max score from programming tasks
    export EX0_MAX_SCORE=2
    export EX1_MAX_SCORE=10
    export EX2_MAX_SCORE=10

    echo Global variables updated
    echo ================
    echo STARTING STEP 2
    echo ================
    if [ "$ASSESSMENT_EX" == "ex1" ]
    then
        ./scripts/npm_start.sh $REACT_PROJ_DIR $REACT_BASE_DIR
    fi
    ./scripts/step_2.sh
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
    ./scripts/step_3.sh
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
    ./scripts/step_4.sh
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
    ./scripts/step_5.sh
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
    ./scripts/step_6.sh
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
    ./scripts/step_7.sh
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
    ./scripts/step_8.sh
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
