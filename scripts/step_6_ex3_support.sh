#!/bin/bash

# Move project files for npm dev server
robot \
    -i "$et" \
    -d $TESTS_DIR/../results/"$ASSESSMENT_EX"/step_6/ex3_support_step/"$(basename "$sut")"/ \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v EX_NUM:"$ASSESSMENT_EX" \
    -v DYNA_DIR:"$REACT_PROJ_DIR" \
    -v RES_DIR:"$RESOURCES_DIR" \
    -v SUT_DIR:"$sut" \
    $TASKS_DIR/support_tasks.robot

# Build CI and start run
cd $DIR
./scripts/npm_run.sh $REACT_PROJ_DIR

# Wait for the npm to be ready
HOST="localhost 3001"
WAIT_TIME=3
PING=true
req_num=0
echo "Will perform up to 20 requests while waiting for npm start."
while [[ $PING == true && $req_num < 61 ]]
do
    ((req_num=req_num+1))
    nc -vz ${HOST}
    if [ $? -ne 0 ]
    then
        echo "Waiting for npm start to be ready (req# $req_num)..."
        sleep $WAIT_TIME
    else
        PING=false
    fi
done

# Run tests
robot \
    --name  "$(basename "$sut") dynamic tests" \
    -d $TESTS_DIR/../results/"$ASSESSMENT_EX"/"$(basename "$sut")"/dynamic/ \
    -i $et \
    -v TEST_SUBJECT_DIR:"$sut" \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v STUDENT_REPORT_ROW:${summaryRowPos} \
    -v DYNA_FOLDER:"$REACT_PROJ_DIR" \
    -v REACT_APP_ADDR:"http://localhost:3000" \
    -v REACT_SERVER_ADDR:"http://localhost:3001" \
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

# Kill node process and empty mongo db collection
pkill -f node
mongosh --eval 'db.ex3tests.remove( { } )' &